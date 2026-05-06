# STRATEGIES/

Formal strategy specs — one folder per strategy.

The top-level [`STRATEGIES.md`](../STRATEGIES.md) is the index; this folder holds the actual specs.

Half-formed ideas start as `notes.md` inside the strategy's own folder with `status: example` or `draft` in the spec. A strategy is ready to promote to `paper-trading` once it has:

- A defined universe (specific tickers / asset class / filter)
- Explicit entry rule
- Explicit exit rule (time, target, stop)
- Position sizing rule
- Risk caps (per-position, portfolio-wide)
- At least one backtest summary in `backtests/`

## Layout

```
<strategy-name>/
├── spec.md         ← formal spec (this is the contract)
├── notes.md        ← scratchpad, open questions, references
└── backtests/      ← per-run backtest summaries
```

## spec.md template

```markdown
---
name: <strategy-name>
class: trend-following | mean-reversion | breakout | pairs | event-driven | other
status: example | draft | paper-trading | live | retired
owner: <person>
last-reviewed: YYYY-MM-DD
---

# <strategy-name>

## Universe
<tickers / filter — be specific>

## Signal
**Entry:** <precise rule>
**Exit:** <precise rule — target, stop, and/or time-based>

## Sizing
<formula — fixed $, % equity, vol-targeted, etc.>

## Risk
- Per-position stop: <%>
- Max concurrent positions: <n>
- Daily loss cap: <%>

## Backtest
- Period: <range>
- Result: link to `backtests/<file>` or `DATA/backtests/<file>`

## Known weaknesses
<honest list — regimes where this fails>
```

## Status meaning

See [`../STRATEGIES.md`](../STRATEGIES.md) for the canonical status definitions.

The current scaffold ships three `example` strategies to demonstrate the layout. **They are not decided strategies** — universe, sizing, and risk caps are placeholders until you fill them in.
