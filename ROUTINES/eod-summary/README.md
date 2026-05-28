# eod-summary

End-of-day summary — runs 16:15 weekdays (15 min after US close).

## Purpose

Daily journal: market close, narrative, positions/trades/P&L, tomorrow's setup.

## Cadence

`15 16 * * 1-5` — weekdays at 16:15 local time (ET).

## Output

Appends one block to `ROUTINES/eod-summary/daily/<YYYY-MM-DD>.md` per run.

## Status

Scaffolded. Not yet scheduled.

## Blocked by

- **Broker integration** — positions/trades/P&L sections need the `alpaca-broker` skill (not started). Until then those sections will say `(not wired)`; market close + narrative still publish from public data.

## Future: Google Docs publish

Same as `market-open-scan` — markdown is the source of truth; Google Docs mirroring can layer on once `/schedule` and broker are live.
