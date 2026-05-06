---
name: mean-reversion-rsi
class: mean-reversion
status: example
owner: skelly1313
last-reviewed: 2026-05-06
---

# mean-reversion-rsi

> **Example template** — textbook short-term mean-reversion archetype. Numbers and
> universe are placeholders; replace every `<TBD>` before promoting to `draft`.

## Universe
`<TBD>` — example placeholder: liquid US equities with average daily volume above a threshold (e.g. ADV > 1M shares), excluding leveraged ETFs and biotech.

## Signal
**Entry:** go long when RSI(`<TBD>`) drops below `<TBD>` on daily close, AND price is above the `<TBD>`-day SMA (regime filter).
- RSI period: `<TBD>` (textbook: 2–14, Connors uses 2)
- RSI oversold threshold: `<TBD>` (textbook: 5–30)
- Trend filter: price > `<TBD>`-day SMA (textbook: 200-day)

**Exit:** close when RSI(`<TBD>`) crosses above `<TBD>` (textbook: 50–70), OR time-stop after `<TBD>` bars (textbook: 5–10), OR hard stop (see Risk).

## Sizing
`<TBD>` — example placeholder: fixed % of equity per trade, scaled inversely with realized volatility.

## Risk
- Per-position stop: `<TBD>%` (example: 4–6% below entry)
- Max concurrent positions: `<TBD>` (example: 10 — mean-reversion benefits from breadth)
- Daily loss cap: `<TBD>%` (example: 2% of equity)

## Backtest
- Period: not run
- Result: _none yet — see `backtests/`_

## Known weaknesses
- Catastrophic in trend / news-driven sell-offs — "buying the dip" can mean buying into a multi-week decline. Trend filter mitigates but doesn't eliminate.
- Heavily dependent on the universe — single-name reversion in fundamentally broken stocks is fatal. Liquid index components reduce this.
- Fade-the-move strategies have positive hit rate but negative skew (small wins, occasional large losses).
- Sensitive to slippage and short-term data quality; backtests on close-to-close prices can overstate edge.
