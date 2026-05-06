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

| Routine | Where | Cadence | Status | Purpose |
| --- | --- | --- | --- | --- |
| `memory-sync` | local | `0 8,12,16,20 * * 1-5` | **scheduled** | Mirror local Claude memory → repo `MEMORY/` |
| `daily-health-check` | local | `0 9 * * 1-5` | **scheduled** | Morning check: memory drift, routine coverage, task health, git state |
| `market-open-scan` | local | `30 9 * * 1-5` | proposed | Pre-market summary (blocked: data source not chosen) |
| `eod-summary` | local | `15 16 * * 1-5` | proposed | End-of-day P&L + journal entry (blocked: broker integration not built) |

See each routine's `README.md`.

## Decisions

- **Broker:** Alpaca, starting on paper (`paper-api.alpaca.markets`).

## Open decisions

- Market data — Alpaca data is bundled with broker access, but is it enough? (Polygon / Databento / Tiingo for upgrades.)
- Language / runtime (Python? Node? Both?)
- Strategy class (mean reversion / momentum / pairs / event-driven)
- Asset universe (equities only? +crypto via Alpaca?)
- Capital + risk caps
