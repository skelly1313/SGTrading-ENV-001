# daily-health-check

Morning sanity check — runs at 09:00 weekdays.

## Purpose

Catch drift and gaps early, before they become incidents:

1. **Memory drift** — is local Claude memory in sync with repo `MEMORY/`?
2. **Routine coverage** — do all routines in `AGENTS.md` have a `prompt.md`?
3. **Scheduled task health** — are scheduled tasks running and not overdue?
4. **Git state** — any uncommitted changes in the repo?

## Cadence

`0 9 * * 1-5` — weekdays at 09:00 local time.

## Output

Appends one block to `ROUTINES/daily-health-check/daily/<YYYY-MM-DD>.md` per run.
Prints `overall: GREEN / YELLOW / RED — <summary>` to stdout.

## Safety

Read-only. Never modifies files, never resolves conflicts, never commits anything.
