# AGENTS

## Skills

| Skill | Purpose | Status |
| --- | --- | --- |
| `memory-sync` | Sync Claude auto-memory between local and this repo | active |
| `daily-health-check` | Detect drift: memory, routine coverage, task health, git state | active |
| `telegram-notify` | Send alerts via Telegram bot ([`LIB/notify.ps1`](LIB/notify.ps1)) | scaffold |
| `alpaca-broker` | Place/query orders via Alpaca (paper) | not started |
| `alpaca-data` | Fetch bars/quotes via Alpaca Market Data API | not started |
| `<backtester>` | Run strategy specs against historical data | not started |

## Routines

### Local

| Routine | Cadence | Status | Purpose |
| --- | --- | --- | --- |
| `memory-sync` | `0 8,12,16,20 * * 1-5` | scheduled | Mirror local Claude memory ↔ repo `MEMORY/` |
| `daily-health-check` | `0 9 * * 1-5` | scheduled | Morning health check |
| `market-open-scan` | `0 8 * * 1-5` | scaffold | Pre-market AM brief (blocked: data source) |
| `eod-summary` | `15 16 * * 1-5` | scaffold | End-of-day report (blocked: broker) |

### Cloud

| Routine | Cadence | Status | Purpose |
| --- | --- | --- | --- |
| _(none yet)_ | — | — | — |
