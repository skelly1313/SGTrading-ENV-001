---
name: memory-sync
description: Mirror Claude auto-memory between local dir and repo MEMORY/
---

Sync Claude's local auto-memory with this repo's `MEMORY/` folder.
Read [`README.md`](README.md) before running.

## Paths

- **Local:** `~/.claude/projects/C--Users-djske-OneDrive-Desktop-SG-Trading/memory/`
- **Repo:** `<repo-root>/MEMORY/`
- **State:** `<repo-root>/ROUTINES/memory-sync/state.json` (gitignored)

## Steps

### 1. Detect mode

- If local dir missing or empty AND `MEMORY/` non-empty → **mode = pull** (repo → local).
- If `MEMORY/` empty AND local non-empty → **mode = push** (local → repo).
- If both non-empty → **mode = bidirectional** (file-by-file based on mtime + SHA).
- If both empty → no-op, log and exit.

### 2. Compute changes

For each `.md` file in either side:

- Compare against `state.json` (which records last-known SHA per file).
- Classify: `unchanged` | `local-newer` | `repo-newer` | `both-changed` | `local-only` | `repo-only`.

### 3. Apply (additive only)

- `local-only` → copy to repo.
- `repo-only` → copy to local.
- `local-newer` → overwrite repo copy.
- `repo-newer` → overwrite local copy.
- `both-changed` → **STOP**. Report conflict, do not modify either side.
- `unchanged` → skip.

Do not delete files. Tombstones (`MEMORY/.tombstones`) handle deletions out-of-band.

### 4. Update index

If any file in `MEMORY/` was added or removed, refresh `MEMORY/MEMORY.md` —
one line per memory file: `- [<name>](<file>) — <description from frontmatter>`.

### 5. Commit + push

If any repo-side files changed:

```
git add MEMORY/
git commit -m "memory-sync: <N> files updated (<UTC timestamp>)"
git push origin main
```

If push fails (network down, conflict on remote): log it, do not retry, leave changes staged for next run.

### 6. Update state + log

- Write new `state.json` with current SHA per file + UTC timestamp.
- Append summary to `daily/<YYYY-MM-DD>.md`:

```
## <UTC timestamp>
mode: push|pull|bidirectional
changed: <list>
conflicts: <list>
commit: <sha or "none">
```

## Constraints

- DO NOT auto-resolve conflicts. Always defer to operator.
- DO NOT delete files. Ever.
- DO NOT push if any file outside `MEMORY/` is staged — abort and warn.
- DO NOT log memory file *contents* into daily logs — just filenames.
