#!/usr/bin/env python3
"""
memory-sync — mirror Claude auto-memory between local dir and repo MEMORY/.

Runs without Claude in the loop. Safe to invoke from Task Scheduler / cron / a
Claude routine prompt that calls Bash. Stdlib only.

Exit codes:
  0 = success (in-sync or applied changes)
  1 = conflict detected, no changes applied
  2 = unrecoverable error
"""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
MEMORY_REPO = REPO_ROOT / "MEMORY"
MEMORY_LOCAL = Path.home() / ".claude" / "projects" / \
    "C--Users-djske-OneDrive-Desktop-SG-Trading" / "memory"
STATE_FILE = Path(__file__).resolve().parent / "state.json"
DAILY_DIR = Path(__file__).resolve().parent / "daily"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def list_md(root: Path) -> dict[str, str]:
    """Return {relative_path: sha256} for *.md files under root."""
    if not root.exists():
        return {}
    out: dict[str, str] = {}
    for p in root.rglob("*.md"):
        if not p.is_file():
            continue
        rel = p.relative_to(root).as_posix()
        if rel.startswith(".") or "/." in rel:
            continue
        out[rel] = sha256(p)
    return out


def load_state() -> dict:
    if not STATE_FILE.exists():
        return {"last_sync_utc": None, "files": {}}
    try:
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except Exception:
        return {"last_sync_utc": None, "files": {}}


def save_state(state: dict) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=2), encoding="utf-8")


def classify(local: dict[str, str], repo: dict[str, str],
             prev: dict[str, str]) -> dict[str, list[str]]:
    """Return {action: [paths]} based on three-way diff."""
    actions = {
        "local_only": [],
        "repo_only": [],
        "local_newer": [],
        "repo_newer": [],
        "both_changed": [],
        "unchanged": [],
    }
    all_keys = set(local) | set(repo)
    for k in sorted(all_keys):
        l, r, p = local.get(k), repo.get(k), prev.get(k)
        if l and not r:
            actions["local_only"].append(k)
        elif r and not l:
            actions["repo_only"].append(k)
        elif l == r:
            actions["unchanged"].append(k)
        else:
            l_changed = l != p
            r_changed = r != p
            if l_changed and not r_changed:
                actions["local_newer"].append(k)
            elif r_changed and not l_changed:
                actions["repo_newer"].append(k)
            else:
                actions["both_changed"].append(k)
    return actions


def copy_file(src_root: Path, dst_root: Path, rel: str) -> None:
    src = src_root / rel
    dst = dst_root / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def refresh_index() -> bool:
    """Rebuild MEMORY/MEMORY.md from frontmatter of sibling files."""
    entries = []
    for p in sorted(MEMORY_REPO.glob("*.md")):
        if p.name == "MEMORY.md" or p.name == "README.md":
            continue
        name = p.stem
        desc = ""
        try:
            text = p.read_text(encoding="utf-8")
        except Exception:
            continue
        if text.startswith("---"):
            end = text.find("\n---", 4)
            if end != -1:
                fm = text[4:end]
                for line in fm.splitlines():
                    line = line.strip()
                    if line.startswith("name:"):
                        name = line.split(":", 1)[1].strip()
                    elif line.startswith("description:"):
                        desc = line.split(":", 1)[1].strip()
        entries.append(f"- [{name}]({p.name}) — {desc}" if desc
                       else f"- [{name}]({p.name})")

    index_path = MEMORY_REPO / "MEMORY.md"
    new_body = ("\n".join(entries) + "\n") if entries else \
        "- _(empty — no synced memories yet. The `memory-sync` routine will populate this.)_\n"
    old_body = index_path.read_text(encoding="utf-8") if index_path.exists() else ""
    if new_body != old_body:
        index_path.write_text(new_body, encoding="utf-8")
        return True
    return False


def git(*args: str) -> tuple[int, str]:
    p = subprocess.run(
        ["git", "-C", str(REPO_ROOT), *args],
        capture_output=True, text=True
    )
    return p.returncode, (p.stdout + p.stderr).strip()


def commit_and_push(changed_count: int) -> str | None:
    rc, _ = git("diff", "--quiet", "--", "MEMORY/")
    rc2, _ = git("diff", "--cached", "--quiet", "--", "MEMORY/")
    if rc == 0 and rc2 == 0:
        return None
    rc, out = git("status", "--porcelain")
    outside = [
        ln for ln in out.splitlines()
        if ln[3:].strip() and not ln[3:].strip().startswith("MEMORY/")
    ]
    if outside:
        return f"REFUSED: untracked changes outside MEMORY/: {outside[:5]}"
    git("add", "MEMORY/")
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%MZ")
    msg = f"memory-sync: {changed_count} files updated ({ts})"
    rc, out = git("commit", "-m", msg)
    if rc != 0:
        return f"commit failed: {out}"
    rc, out = git("push", "origin", "main")
    if rc != 0:
        return f"pushed locally, push to remote failed: {out}"
    rc, sha = git("rev-parse", "--short", "HEAD")
    return f"committed+pushed {sha}"


def write_daily(report: str) -> None:
    DAILY_DIR.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y-%m-%d")
    log = DAILY_DIR / f"{today}.md"
    with log.open("a", encoding="utf-8") as f:
        f.write(report)


def main() -> int:
    local_files = list_md(MEMORY_LOCAL)
    repo_files = list_md(MEMORY_REPO)
    state = load_state()
    prev = state.get("files", {})

    if not local_files and not repo_files:
        print("both empty — nothing to do")
        return 0

    if not local_files and repo_files:
        mode = "pull"
    elif local_files and not repo_files:
        mode = "push"
    else:
        mode = "bidirectional"

    actions = classify(local_files, repo_files, prev)

    if actions["both_changed"]:
        report = (
            f"\n## {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%MZ')}\n"
            f"mode: {mode}\n"
            f"STATUS: CONFLICT — both sides changed since last sync\n"
            f"conflicting files:\n"
            + "\n".join(f"  - {p}" for p in actions["both_changed"])
            + "\nNo changes applied. Resolve manually.\n"
        )
        write_daily(report)
        print(report)
        return 1

    changed = 0
    MEMORY_REPO.mkdir(parents=True, exist_ok=True)
    if mode != "pull-only":
        MEMORY_LOCAL.mkdir(parents=True, exist_ok=True)

    for rel in actions["local_only"] + actions["local_newer"]:
        copy_file(MEMORY_LOCAL, MEMORY_REPO, rel)
        changed += 1
    for rel in actions["repo_only"] + actions["repo_newer"]:
        copy_file(MEMORY_REPO, MEMORY_LOCAL, rel)
        changed += 1

    index_changed = refresh_index()
    if index_changed:
        changed += 1

    new_state = {
        "last_sync_utc": datetime.now(timezone.utc).isoformat(),
        "files": list_md(MEMORY_REPO),
    }
    save_state(new_state)

    commit_result = commit_and_push(changed) if changed else None

    summary_lines = [
        f"\n## {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%MZ')}",
        f"mode: {mode}",
        f"changed: {changed}",
    ]
    for k in ("local_only", "repo_only", "local_newer", "repo_newer"):
        if actions[k]:
            summary_lines.append(f"  {k}: {actions[k]}")
    if commit_result:
        summary_lines.append(f"git: {commit_result}")
    elif changed == 0:
        summary_lines.append("git: nothing to commit")
    report = "\n".join(summary_lines) + "\n"
    write_daily(report)
    print(report)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"FATAL: {e}", file=sys.stderr)
        sys.exit(2)
