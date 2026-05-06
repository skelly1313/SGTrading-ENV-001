# AGENTS

Index of skills and routines for the SG Trading project.

## Skills

| Skill | Purpose | Status |
| --- | --- | --- |
| `memory-sync` | Sync Claude auto-memory between local and this repo | **active** |
| `daily-health-check` | Detect drift: memory, routine coverage, task health, git state | **active** |
| `alpaca-broker` | Place/query orders via Alpaca (paper) | not started |
| `alpaca-data` | Fetch bars/quotes via Alpaca Market Data API | not started |
| `<backtester>` | Run strategy specs against historical data | not started |
| `telegram-notify` | Send alerts via Telegram bot ([`LIB/notify.ps1`](LIB/notify.ps1)) | scaffold |

See [`SKILL-EXAMPLE.md`](SKILL-EXAMPLE.md) for the per-skill template.

## Routines

Routines run on a schedule. **Local** routines run on this machine via Claude Code
(`mcp__scheduled-tasks__*`). **Cloud** routines run as remote agents via
claude.ai (`/schedule` skill). Both use cron in local time.

### Local routines (Claude Code)

| Routine | Cadence | Status | Purpose |
| --- | --- | --- | --- |
| `memory-sync` | `0 8,12,16,20 * * 1-5` | **scheduled** | Mirror local Claude memory ↔ repo `MEMORY/` |
| `daily-health-check` | `0 9 * * 1-5` | **scheduled** | Morning check: memory drift, routine coverage, task health, git state |
| `market-open-scan` | `30 9 * * 1-5` | proposed | Pre-market summary (blocked: data source not chosen) |
| `eod-summary` | `15 16 * * 1-5` | proposed | End-of-day P&L + journal entry (blocked: broker integration not built) |

Manage with: `mcp__scheduled-tasks__list_scheduled_tasks` /
`create_scheduled_task` / `update_scheduled_task`.
Each has a folder under `ROUTINES/<name>/` with `README.md` + `prompt.md`.

### Cloud routines (claude.ai remote agents)

| Routine | Cadence | Status | Purpose |
| --- | --- | --- | --- |
| _(none registered yet)_ | — | — | — |

Manage with the `/schedule` skill. Use cloud routines for things that must run
even when this machine is off (overnight data pulls, alerting, anything
account-bound rather than machine-bound).

**Candidates to consider once strategy is defined:**
- `news-sentiment-pull` — overnight news scrape for the watchlist
- `weekend-research-digest` — Saturday summary of last week + open questions
- `broker-balance-watch` — periodic Alpaca account/position snapshot

Do not create cloud routines until the underlying skill (data source, broker
client, etc.) actually exists.

## Decisions

- **Broker:** Alpaca, starting on paper (`paper-api.alpaca.markets`).

## Open decisions

- Market data — Alpaca data is bundled with broker access, but is it enough? (Polygon / Databento / Tiingo for upgrades.)
- Language / runtime (Python? Node? Both?)
- Strategy class (mean reversion / momentum / pairs / event-driven)
- Asset universe (equities only? +crypto via Alpaca?)
- Capital + risk caps
