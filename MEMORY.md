# MEMORY (project-level)

Durable, cross-cutting facts and conventions for SG Trading.

The **per-conversation auto-memory** (Claude's working memory) lives in
[`MEMORY/`](MEMORY/) — that's where named facts about the user, feedback, project
state, and references go, indexed by `MEMORY/MEMORY.md`.

This file is for things broader than any one memory entry: project-wide
conventions and pointers.

---

## Cross-cutting facts

- **Project goal:** trading bot — strategy not yet defined.
- **Repo:** `https://github.com/skelly1313/SGTrading-ENV-001`.
- **Owner:** solo project (skelly1313).
- **Notification channel:** TBD — credentials will live in `SECRETS.local.md` (gitignored).
- **Broker / data provider:** not chosen.

## Sources of truth

| Item | Source of truth |
| --- | --- |
| Skill catalog | [`AGENTS.md`](AGENTS.md) |
| Auto-memory index | [`MEMORY/MEMORY.md`](MEMORY/MEMORY.md) |
| Per-routine README | `ROUTINES/<routine>/README.md` |
| Per-routine prompt | `ROUTINES/<routine>/prompt.md` |
| Per-run history | `ROUTINES/<routine>/daily/<YYYY-MM-DD>.md` |
| Strategy specs | `STRATEGIES/<name>.md` |
| Credentials (template) | [`SECRETS.md`](SECRETS.md) |
| Credentials (real) | `SECRETS.local.md` (gitignored) |

## Conventions

- Daily-log filenames use the local date `YYYY-MM-DD`; convert relative dates ("yesterday") before writing.
- Inside files, prefer UTC for timestamps from external APIs; mark local times explicitly.
- Routines append to daily logs (never overwrite). Multiple runs in a day get their own dated heading.
- Use `~/` (not absolute home paths) for portability across machines.
- Real secrets never go in tracked files. Period.

## Change log

- **2026-05-06** — initial scaffold filled in; remote pointed at `SGTrading-ENV-001`.
