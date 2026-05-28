# SG Trading — Claude Project Context

## Mission

Build a trading bot. Strategy is **not yet defined** — early stage, exploration mode.
Don't assume strategy details; ask before fabricating rules, indicators, or thresholds.

## Repo role

This repo (`SGTrading-ENV-001`) is the **source of truth** for:

- Project memory (`MEMORY/`)
- Routines and their prompts (`ROUTINES/`)
- Strategy specs (`STRATEGIES/` — layout TBD)
- Skill catalog (`AGENTS.md`)

## Working directory layout

| Path | Purpose |
|---|---|
| `MEMORY/` | Claude auto-memory. Index in `MEMORY/MEMORY.md`. |
| `STRATEGIES/` | Strategy specs — layout TBD, do not add files yet. |
| `DATA/` | Gitignored — cached market data, backtests, scratch. |
| `ROUTINES/` | Scheduled tasks and callable scripts (each has its own folder). |

## Conventions

- Dates: absolute `YYYY-MM-DD`. Timestamps in UTC unless marked local.
- Don't write strategy rules without explicit user input.
- Don't put real credentials in `SECRETS.md`. Use `SECRETS.local.md` (gitignored).
- Before committing, sanity-check: no real keys, no large data files.

## Decisions

- **Broker:** Alpaca, starting on paper (`paper-api.alpaca.markets`).

## Open decisions

- Market data source (Alpaca-bundled vs Polygon/Databento/Tiingo)
- Language / runtime (Python? Node? Both?)
- Strategy class (mean reversion / momentum / pairs / event-driven)
- Asset universe (equities only? +crypto via Alpaca?)
- Capital + risk caps

## File roles

- **AGENTS.md** — index only. Skills + Routines tables.
- **CLAUDE.md** — this file. Project context, conventions, decisions, open questions.
- **MEMORY.md** — project-level cross-cutting facts; auto-memory index lives in `MEMORY/MEMORY.md`.
- **STRATEGIES/** — strategy specs (layout TBD).
- **SECRETS.md** — credential template. Real values go in `SECRETS.local.md` (gitignored).
- **ROUTINES/<name>/** — per-routine `README.md` + `prompt.md` (+ scripts).
