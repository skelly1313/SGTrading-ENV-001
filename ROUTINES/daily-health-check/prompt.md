---
name: daily-health-check
description: Morning check — memory drift, routine coverage, scheduled task health, git state
---

Morning health check for the SG Trading project. Read-only — do not modify files, do not resolve conflicts, do not commit anything.

Working directory: `C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS`

## Check 1: Memory drift

Run the memory-sync dry-run (no changes applied):
```
powershell -File "ROUTINES/memory-sync/sync.ps1" -DryRun
```
Flag any file classified as anything other than `unchanged`. List filenames only.

## Check 2: Routine coverage

Read `AGENTS.md`. For each routine in the Routines table:
- Does `ROUTINES/<name>/` directory exist?
- Does `ROUTINES/<name>/prompt.md` exist?

List missing items as gaps.

## Check 3: Scheduled task health

List all scheduled tasks. For each task, flag if:
- `lastRunAt` is missing (never run)
- `lastRunAt` is more than 2x the expected interval ago:
  - `memory-sync`: expected every 4h on weekdays
  - `daily-health-check`: expected every 24h on weekdays

## Check 4: Git state

Run:
```
git -C "C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS" status --short
```
Report any modified tracked files or uncommitted staged changes.

## Output

Append to `ROUTINES/daily-health-check/daily/<YYYY-MM-DD>.md`:

```
## <UTC timestamp> — daily-health-check
memory-drift: none | <list of filenames>
routine-gaps: none | <list>
task-health: all OK | <list of overdue/never-run>
git: clean | dirty (<details>)
overall: GREEN | YELLOW | RED
```

Print only the `overall:` line plus a one-sentence summary to stdout.

## Grading

- **GREEN**: all checks pass
- **YELLOW**: non-blocking gap — e.g. drift detected but no conflict, routine missing prompt but folder exists
- **RED**: conflict detected, task overdue by >2x interval, or git is dirty
