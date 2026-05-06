# STRATEGIES/

Formal strategy specs — concrete enough to backtest and (eventually) trade.

A spec graduates here from `DOCS/strategies/` once it has:

- A defined universe (specific tickers / asset class)
- Explicit entry rule
- Explicit exit rule (time, target, stop)
- Position sizing rule
- Risk caps (per-position, portfolio-wide)

## Spec template

```markdown
---
name: <strategy-name>
status: draft | paper-trading | live | retired
owner: <person>
last-reviewed: YYYY-MM-DD
---

# <strategy-name>

## Universe
<tickers / filter>

## Signal
**Entry:** <precise rule>
**Exit:** <precise rule>

## Sizing
<formula>

## Risk
- Per-position stop: <%>
- Max concurrent positions: <n>
- Daily loss cap: <%>

## Backtest
- Period: <range>
- Result: link to `DATA/backtests/<file>`

## Known weaknesses
<honest list>
```

Nothing here yet — strategy is undefined.
