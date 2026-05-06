---
name: opening-range-breakout
class: breakout
status: example
owner: skelly1313
last-reviewed: 2026-05-06
---

# opening-range-breakout

> **Example template** — textbook intraday breakout archetype. Numbers and
> universe are placeholders; replace every `<TBD>` before promoting to `draft`.

## Universe
`<TBD>` — example placeholder: liquid US equities or index ETFs with tight spreads at the open (e.g. SPY, QQQ, top decile by ADV).

## Signal
**Entry:** at market open, define the opening range as the high/low of the first `<TBD>` minutes (textbook: 15 or 30).
- Long entry: price breaks above opening-range high after the range is set.
- Short entry: price breaks below opening-range low after the range is set.
- Optional volume filter: only trigger if breakout bar volume > `<TBD>×` recent average.

**Exit:** close all positions by `<TBD>` (textbook: 15:55 ET — flat into the close), OR target hit, OR stop hit (see Risk).

## Sizing
`<TBD>` — example placeholder: risk-fixed sizing — position size = `(daily_risk_$) / (entry − stop)`.

## Risk
- Per-position stop: opposite side of the opening range, OR `<TBD>%` adverse move, whichever is tighter.
- Max concurrent positions: `<TBD>` (example: 1–3 — intraday concentration is fine for this style)
- Daily loss cap: `<TBD>%` of equity (example: 1–2%, hit two consecutive losers and stop trading the day)

## Backtest
- Period: not run
- Result: _none yet — see `backtests/`_

## Known weaknesses
- Requires intraday data and realistic intraday execution modeling — backtests on daily bars cannot represent this strategy.
- False breakouts in low-volatility / range-bound days; volume filter helps but won't eliminate them.
- Slippage on fast-moving breakout bars can be substantial — paper-trade results may overstate live edge.
- Highly regime-dependent — works in trending / volatile environments, fails in compressed / pre-event markets.
- Requires reliable execution at exact times; broker latency and data feed quality matter more than for daily strategies.
