---
name: moving-average-crossover
class: trend-following
status: example
owner: skelly1313
last-reviewed: 2026-05-06
---

# moving-average-crossover

> **Example template** — the archetype is real (textbook trend-following), but every
> numeric parameter and the universe below are placeholders. Replace `<TBD>` values
> before promoting to `draft`.

## Universe
`<TBD>` — example placeholder: liquid US large-caps, e.g. SPY / QQQ / top-100 by ADV.

## Signal
**Entry:** go long when fast SMA crosses above slow SMA on daily close.
- Fast SMA: `<TBD>` bars (textbook: 20–50)
- Slow SMA: `<TBD>` bars (textbook: 100–200)

**Exit:** close when fast SMA crosses back below slow SMA, OR stop hit (see Risk).

## Sizing
`<TBD>` — example placeholder: equal-weight across active positions, capped at N concurrent.

## Risk
- Per-position stop: `<TBD>%` (example: 5–8% below entry)
- Max concurrent positions: `<TBD>` (example: 5)
- Daily loss cap: `<TBD>%` (example: 2% of equity)

## Backtest
- Period: not run
- Result: _none yet — see `backtests/`_

## Known weaknesses
- Whipsaws in range-bound / choppy markets — many small losses between trends.
- Late entries by design (lagging indicator).
- Performance highly sensitive to the fast/slow window choice; param-tuning risks overfitting.
- Single-leg long-only version has no protection in bear regimes; consider regime filter or short side.
