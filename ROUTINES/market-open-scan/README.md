# market-open-scan

Pre-market AM brief — runs 08:00 weekdays.

## Purpose

Snapshot of factual market context before US open: index futures, movers, calendar, overnight headlines.

## Cadence

`0 8 * * 1-5` — weekdays at 08:00 local time (ET).

## Output

Appends one block to `ROUTINES/market-open-scan/daily/<YYYY-MM-DD>.md` per run.
Prints a one-sentence open posture to stdout.

## Status

Scaffolded. Not yet scheduled — pending `/schedule` (currently failing remote connect) and a chosen data source.

## Blocked by

- **Data source** — Alpaca data may cover futures and pre-market movers; calendar and earnings likely need Polygon / similar. Pick before scheduling.

## Future: Google Docs publish

Once a data source is wired, an optional second step can mirror the markdown to a Google Doc via the Chrome MCP (runs locally in the user's browser). The markdown file in this folder remains the source of truth.
