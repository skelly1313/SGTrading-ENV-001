# daily-health-check

Verifies that the agent's actual setup matches what's documented in this folder
**and** that local Claude memory is in sync with the repo's `MEMORY/`.
Reports drift; does not auto-fix.

## Cadence

`0 9 * * 1-5` — weekdays at 09:00 local. See [`prompt.md`](prompt.md).

## What it checks

1. **Secrets populated** — every key in `SECRETS.md` has a real value (no placeholders, no blanks). Alpaca URL validated against expected environment.
2. Each skill listed in [`AGENTS.md`](../../AGENTS.md) (status `scaffold` or beyond) exists where it should and its required secrets are present in `SECRETS.md`.
3. Each routine folder under `ROUTINES/` has a matching scheduled task (skip routines marked `proposed`).
4. The cron schedule on each scheduled task matches the cadence stated in its README.
5. **Memory parity** — local `~/.claude/.../memory/` vs repo `MEMORY/`. Flags `LOCAL_ONLY`, `REPO_ONLY`, `DIFFER`, or `IN_SYNC`.
6. **Repo hygiene** — `.gitignore` has the expected entries, no secrets or data files are tracked.

## Outputs

- Notification to the channel configured in `SECRETS.md`.
- Appended report at `daily/<YYYY-MM-DD>.md`.

## Discipline

- Never edits `SECRETS.md`, `AGENTS.md`, or any routine's `README.md` to "fix" drift — drift is reported, the operator decides which side to update.
- Never resolves memory conflicts. That's a manual call.
- Never commits or pushes — that's `memory-sync`'s job.
