# MEMORY (project-level)

Durable, cross-cutting facts and conventions for SG Trading.

The **per-conversation auto-memory** (Claude's working memory) lives in
[`MEMORY/`](MEMORY/) — indexed by `MEMORY/MEMORY.md`.

This file is for things broader than any one memory entry: project-wide
conventions and pointers.

---

## Cross-cutting facts

- **Project goal:** trading bot — strategy not yet defined.
- **Repo:** `https://github.com/skelly1313/SGTrading-ENV-001`.
- **Owner:** solo project (skelly1313).
- **Broker:** Alpaca (paper).
- **Notification channel:** Slack (credentials TBD, will live in `SECRETS.local.md`).

## Sources of truth

| Item | Source of truth |
| --- | --- |
| Skill catalog | [`AGENTS.md`](AGENTS.md) |
| Auto-memory index | [`MEMORY/MEMORY.md`](MEMORY/MEMORY.md) |
| Per-routine README | `ROUTINES/<routine>/README.md` |
| Per-routine prompt | `ROUTINES/<routine>/prompt.md` |
| Strategy specs | _layout TBD — see `STRATEGIES/README.md`_ |
| Credentials (template) | [`SECRETS.md`](SECRETS.md) |
| Credentials (real) | `SECRETS.local.md` (gitignored) |

## Conventions

- Daily-log filenames use the local date `YYYY-MM-DD`.
- Inside files, prefer UTC for external-API timestamps; mark local times explicitly.
- Use `~/` (not absolute home paths) for portability across machines.
- Real secrets never go in tracked files. Period.

## Change log

- **2026-05-06** — initial scaffold filled in; remote pointed at `SGTrading-ENV-001`.
- **2026-05-27** — full reset to clean frame: removed all routines and scheduled tasks; AGENTS.md trimmed to `alpaca` + `slack` only.
