---
name: memory-sync
description: Mirror Claude auto-memory between local dir and repo MEMORY/
---

Sync Claude's local auto-memory with this repo's `MEMORY/` folder.

## Preferred: run the existing script

Do not reimplement the sync logic. Call the script directly:

**PowerShell (primary):**
```powershell
powershell -File "ROUTINES/memory-sync/sync.ps1"
```

**Python (fallback if PS1 unavailable):**
```bash
python ROUTINES/memory-sync/sync.py
```

The script exits 0 (success/in-sync), 1 (conflict — no changes applied), or 2 (fatal).
Capture and report stdout. On exit code 1, surface the conflict list and stop — do not retry.

## Dry-run (inspect without changing)

```powershell
powershell -File "ROUTINES/memory-sync/sync.ps1" -DryRun
```

## Paths

- **Local:** `~/.claude/projects/C--Users-djske-OneDrive-Desktop-SG-Trading/memory/`
- **Repo:** `<repo-root>/MEMORY/`
- **State:** `<repo-root>/ROUTINES/memory-sync/state.json` (gitignored)
- **Daily log:** `<repo-root>/ROUTINES/memory-sync/daily/<YYYY-MM-DD>.md`

## Manual fallback (scripts unavailable)

Only follow these steps if neither script can run:

1. SHA-diff every `.md` in both dirs against `state.json` → classify each file.
2. Apply changes additively (no deletes). Stop on any `both-changed` conflict.
3. Refresh `MEMORY/MEMORY.md` index if any repo-side file changed.
4. `git add MEMORY/ && git commit -m "memory-sync: N files updated (UTC)" && git push origin main`
5. Update `state.json` and append summary to daily log.

## Constraints

- DO NOT auto-resolve conflicts. Surface them, stop, defer to operator.
- DO NOT delete files. Ever.
- DO NOT push if any file outside `MEMORY/` would be committed — abort and warn.
- DO NOT log file contents in daily logs — filenames only.
