# daily-health-check

Verifies that the agent's actual setup matches what's documented in this folder.
Reports drift; does not auto-fix.

## Cadence

`0 9 * * 1-5` — weekdays at 09:00 local. See [`prompt.md`](prompt.md).

## What it checks

1. Each skill listed in [`AGENTS.md`](../../AGENTS.md) exists where it should and has a non-empty, mode-600 credentials file.
2. Each routine folder under `ROUTINES/` has a matching scheduled task (or, if remote, a `prompt.md` and a `README.md`).
3. The cron schedule on each scheduled task matches the cadence stated in its README.

## Outputs

- Notification to the channel configured in [`SECRETS.md`](../../SECRETS.md).
- Appended report at `daily/<YYYY-MM-DD>.md`.

## Discipline

- Never edits `SECRETS.md`, `AGENTS.md`, or any routine's `README.md` to "fix" drift — drift is reported, the operator decides which side to update.
- Credential files stay `chmod 600`.
