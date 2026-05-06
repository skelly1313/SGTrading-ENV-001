# opening-range-breakout — notes

Scratchpad for thesis, open questions, references. Not the contract — `spec.md` is.

## Thesis
The opening auction prints the day's first balance point; once price decisively leaves that initial range, intraday momentum and short-covering / stop-hunting tend to extend the move. Profitable when (a) the universe is liquid enough that breakouts aren't just noise and (b) execution is fast and clean.

## Why this archetype is in the catalog
Demonstrates an intraday-only strategy in the catalog — distinct execution requirements (intraday data, fast fills, end-of-day flat) from the daily-bar strategies above.

## Open questions
- Range length: 5/15/30 minutes — bigger range = higher quality signals, fewer trades.
- Volume filter: which average (5-day, 20-day) and what multiplier?
- Exit logic: ATR-based target, fixed R-multiple (1R, 2R), or time-based?
- Symmetric long/short, or skew toward the prevailing market regime?
- What's the minimum data resolution we need — 1-min bars sufficient, or do we need ticks?

## Open infra dependencies
- Alpaca data feed: 1-min bars are standard, but intraday execution + slippage modeling needs careful validation.
- Paper-trade for at least N sessions before any live capital — ORB results in backtests are notoriously optimistic.

## References
- _Add as we collect them._ Toby Crabel, *Day Trading with Short Term Price Patterns and Opening Range Breakout*.
