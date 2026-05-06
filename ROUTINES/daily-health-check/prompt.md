---
name: daily-health-check
description: Verify agent setup matches the project's documentation and detect memory drift
---

Daily verification that the agent's actual setup matches what's documented,
plus reconciliation between local Claude memory and the repo's `MEMORY/`.
Read-only by default — reports drift, doesn't fix it.

## Steps

### 1. Verify skills

Expected list = the **Skills** table in `<project>/AGENTS.md`. For each skill marked `scaffold` or beyond:

- Skill folder exists where the agent loads skills from.
- Credentials file (if required) exists, is non-empty, and is `chmod 600` (POSIX) / not world-readable (Windows).

Flag any skill folder present on disk but missing from `AGENTS.md` (orphan).
Skip skills marked `not started`.

### 2. Verify routines

Expected list = each subfolder under `<project>/ROUTINES/` that isn't `archive` or `daily-health-check` itself.

For each:

- A scheduled task exists with a matching name (skip for routines marked `proposed` in AGENTS.md).
- The task is enabled.
- Its cron expression matches the cadence in the routine's `README.md`.

Remote routines: just confirm the folder has `prompt.md` and `README.md`.

### 3. Verify memory sync state

- Local memory dir exists: `~/.claude/projects/C--Users-djske-OneDrive-Desktop-SG-Trading/memory/`
- Repo `MEMORY/` exists.
- Compare file lists.
- For files in both: compare SHA-256.

Possible findings:
- `LOCAL_ONLY` files → `memory-sync` hasn't run, or push failed.
- `REPO_ONLY` files → fresh-machine pull pending, or written from cloud Claude.
- `DIFFER` files → both sides changed; conflict — operator must resolve.
- `IN_SYNC` → nothing to do.

### 4. Verify repo hygiene

- `.gitignore` includes `DATA/`, `.DS_Store`, `*.env`, `SECRETS.local.md`, `.claude/`.
- No tracked file matches `*.env`, `credentials.env`, or `SECRETS.local.md`.
- No file in `DATA/` is tracked.

### 5. Report

Open with one of:
- `ALL CLEAR — skills, routines, memory aligned.`
- `ATTENTION:` followed by a bullet list of drift items.

Always emit:

| Check | Expected | Actual | Status |
|---|---|---|---|
| Skills documented vs present | … | … | OK / DRIFT |
| Credential files (count, all 600) | … | … | OK / DRIFT |
| Local routines documented vs scheduled | … | … | OK / DRIFT |
| Remote routines documented (folder presence) | … | … | OK / DRIFT |
| Memory: local vs repo | … | … | OK / DRIFT / CONFLICT |
| Repo hygiene (.gitignore, no leaked secrets) | … | … | OK / DRIFT |

### 6. Notify

Send a one-line summary to the channel configured in `SECRETS.local.md`
(falls back to printing if not configured).

### 7. Persist

Append the full report to `daily/<YYYY-MM-DD>.md` (local date) using append-mode
so multiple runs in a day stack.

Add to `MEMORY.md` only when something durable changes — not for one-off drift.

## Constraints

- DO NOT edit `SECRETS.md`, `SECRETS.local.md`, `AGENTS.md`, or any routine's `README.md` to "fix" drift.
- DO NOT create or delete scheduled tasks.
- DO NOT auto-resolve memory conflicts. Reporting only.
- DO NOT push or commit anything from this routine — that's `memory-sync`'s job.
