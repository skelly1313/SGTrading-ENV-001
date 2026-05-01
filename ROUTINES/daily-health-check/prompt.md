---
name: daily-health-check
description: Verify agent setup matches the project's documentation
---

Daily verification that the agent's actual setup matches what's documented in
this project. Read-only; this routine reports drift, it does not fix it.

## Steps

### 1. Verify skills

Expected list = the **Skills** table in `<project>/AGENTS.md`. For each:

- Skill folder exists where the agent loads skills from.
- Credentials file exists, is non-empty, and is `chmod 600`.

Flag any skill folder present on disk but missing from `AGENTS.md` (orphan).

### 2. Verify routines

Expected list = each subfolder under `<project>/ROUTINES/` that isn't `archive` or `daily-health-check` itself.

For each:

- A scheduled task exists with a matching name.
- The task is enabled.
- Its cron expression matches the cadence in the routine's `README.md`.

Remote routines are not listable from the local scheduler — for those, just confirm the folder has a `prompt.md` and a `README.md`.

### 3. Report

Open with one of:

- `ALL CLEAR — skills + routines aligned.`
- `ATTENTION:` followed by a bullet list of drift items.

Always emit:

| Check | Expected | Actual | Status |
|---|---|---|---|
| Skills documented vs present | … | … | OK / DRIFT |
| Credential files (count, all 600) | … | … | OK / DRIFT |
| Local routines documented vs scheduled | … | … | OK / DRIFT |
| Remote routines documented (folder presence) | … | … | OK / DRIFT |

### 4. Notify

Send a one-line summary to the channel configured in `SECRETS.md`
(`### EXAMPLE_NOTIFY SECRETS` block).

### 5. Persist

Append the full report to `daily/<YYYY-MM-DD>.md` (local date) using `>>` so
multiple runs in a day stack.

Add to `MEMORY.md` only when something durable changes — not for one-off drift.

## Constraints

- DO NOT edit `SECRETS.md`, `AGENTS.md`, or any routine's `README.md` to "fix" drift.
- DO NOT create or delete scheduled tasks. Reporting only.
