# MEMORY

Durable, cross-cutting facts and conventions for this project. Anything that
applies to a single skill or routine belongs in that folder's own `MEMORY.md`.

---

## Cross-cutting facts

- **Notification channel:** `<chat / email / webhook>` — credentials in [`SECRETS.md`](SECRETS.md).
- **Cloud / data tenant:** `<account or tenant identifier>` — see [`SKILL-EXAMPLE.md`](SKILL-EXAMPLE.md).
- **Ticket / wiki tenant:** `<tenant identifier>`.

## Sources of truth

| Item | Source of truth |
| --- | --- |
| Skill catalog | [`AGENTS.md`](AGENTS.md) |
| Per-routine durable facts | `ROUTINES/<routine>/MEMORY.md` |
| Per-routine prompt | `ROUTINES/<routine>/prompt.md` |
| Per-run history | `ROUTINES/<routine>/daily/<YYYY-MM-DD>.md` |
| Credentials | [`SECRETS.md`](SECRETS.md) |

## Conventions

- Daily-log filenames use the local date `YYYY-MM-DD`.
- Inside files, prefer UTC for timestamps from external APIs; mark local times explicitly.
- Routines append to daily logs (never overwrite). Multiple runs in a day get their own dated heading.
- Write to a `MEMORY.md` only when a fact is genuinely durable; ephemera goes in the daily log.
- Use `~/` (not absolute home paths) for portability across machines.

## Change log

- **YYYY-MM-DD** — initial scaffold.
