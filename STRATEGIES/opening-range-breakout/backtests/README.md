# backtests/

Per-run backtest summaries for `opening-range-breakout`.

Filename convention: `<YYYY-MM-DD>-<short-note>.md`.

Each summary includes: parameter set, sample period, equity curve link (in `DATA/backtests/`), key metrics (CAGR, Sharpe, max DD, hit rate, average winner vs. loser, trades-per-day), execution-realism notes (slippage assumed, fill-at-bar-open vs. mid), and conclusions.

**Critical for ORB:** Always document the slippage assumption. Paper backtests that fill at the breakout-bar open can overstate edge by hundreds of bps annually.

Nothing here yet.
