# AGENTS

Index of skills and routines for the SG Trading project.

## Skills

| Skill | Purpose | Status |
| --- | --- | --- |
| `memory-sync` | Sync Claude auto-memory between local and this repo | scaffold |
| `daily-health-check` | Verify skills/routines match docs; detect drift | scaffold |
| `<broker-api>` | Place/query orders via broker (TBD: Alpaca / IBKR / etc.) | not started |
| `<market-data>` | Fetch quotes, bars, fundamentals (TBD provider) | not started |
| `<backtester>` | Run strategy specs against historical data | not started |
| `<notifier>` | Send alerts to chat/email/webhook | not started |

See [`SKILL-EXAMPLE.md`](SKILL-EXAMPLE.md) for the per-skill template.

## Routines

| Routine | Where | Cadence | Purpose |
| --- | --- | --- | --- |
| `daily-health-check` | local | `0 9 * * 1-5` | Detect doc/setup drift; reconcile local vs repo memory |
| `memory-sync` | local | `0 */4 * * *` (proposed) | Mirror local Claude memory → repo `MEMORY/` |
| `market-open-scan` | local | `30 9 * * 1-5` (proposed) | Pre-market summary (TBD once data source picked) |
| `eod-summary` | local | `15 16 * * 1-5` (proposed) | End-of-day P&L + journal entry (TBD) |

See each routine's `README.md`.

## Open decisions

- Broker (Alpaca paper → live? IBKR? Other?)
- Market data provider
- Strategy class (mean reversion / momentum / pairs / event-driven)
- Asset universe (equities / futures / crypto / FX)
- Capital + risk caps
