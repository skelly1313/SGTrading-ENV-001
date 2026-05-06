# SG Trading — Claude Project Context

## Mission

Build a trading bot. Strategy is **not yet defined** — early stage, exploration mode.
Don't assume strategy details; ask before fabricating rules, indicators, or thresholds.

## Repo role

This repo (`SGTrading-ENV-001`) is the **source of truth** for:

- Project memory (mirrored from local Claude memory → `MEMORY/`)
- Routines and their prompts (`ROUTINES/`)
- Strategy specs and research (`STRATEGIES/`, `DOCS/`)
- Skill catalog (`AGENTS.md`)

Local Claude memory at `~/.claude/projects/<encoded>/memory/` is a working cache.
The repo wins on conflict unless local is clearly newer.

## Working directory layout

| Path | Purpose |
|---|---|
| `MEMORY/` | Synced mirror of Claude auto-memory. Index in `MEMORY.md`. |
| `DOCS/research/` | Market research, paper summaries, data notes |
| `DOCS/decisions/` | ADR-style: why we picked X over Y |
| `STRATEGIES/` | Formal specs (entry, exit, sizing, risk). Index in `STRATEGIES.md`; per-strategy scratchpads live in each folder's `notes.md`. |
| `DATA/` | Gitignored — cached market data, backtests |
| `ROUTINES/` | Scheduled tasks (each has README + prompt.md) |

## Conventions

- Dates: absolute `YYYY-MM-DD`. Timestamps in UTC unless marked local.
- Don't write strategy rules without explicit user input — placeholder files are fine, hallucinated rules are not.
- Don't create real credentials in `SECRETS.md`. Use `SECRETS.local.md` (gitignored).
- Routines append to `daily/<date>.md`, never overwrite.
- Before committing, sanity-check: no real keys, no large data files.

## Memory sync model

1. Claude writes memory to local `~/.claude/projects/.../memory/` as usual.
2. The `memory-sync` routine pushes those files to `MEMORY/` in this repo.
3. If local memory is unavailable (different machine, cloud Claude), write directly to `MEMORY/`.
4. `daily-health-check` detects drift between local and repo, reports it, never auto-resolves silently.

## What "done" looks like for this stage

- Scaffold solid, gitignored data dir, sync routine working.
- One real strategy spec drafted (even rough).
- A backtest harness sketched, even if not run.

We're not there yet. Ask before assuming.
