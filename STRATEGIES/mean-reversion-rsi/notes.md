# mean-reversion-rsi — notes

Scratchpad for thesis, open questions, references. Not the contract — `spec.md` is.

## Thesis
Short-term overreactions in liquid equities tend to revert. RSI is a simple bounded oscillator that flags stretched conditions; combined with a long-term trend filter, it scopes the trade to "buying dips in uptrends" rather than catching falling knives.

## Why this archetype is in the catalog
Classic counterpart to trend-following. Different return profile (positive hit rate, negative skew) — useful for diversification at the strategy level.

## Open questions
- RSI period: short (Connors RSI(2)) is well-known; does it still work after broad publication?
- Trend filter: is the 200-day SMA on the *instrument* enough, or do we want a broader index filter (only trade longs when SPY > 200-day)?
- Exit: RSI-based vs. time-based vs. profit-target — which has best risk-adjusted return?
- Universe sizing: how many names do we need to make breadth work?

## References
- _Add as we collect them._ Classic refs: Connors, *Short Term Trading Strategies That Work*.
