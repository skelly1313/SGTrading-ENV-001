# moving-average-crossover — notes

Scratchpad for thesis, open questions, references. Not the contract — `spec.md` is.

## Thesis
Prices trend more often than chance predicts; a slow-MA crossover catches the body of a sustained move while filtering out short-term noise. Works best on instruments with persistent trends and high autocorrelation in returns.

## Why this archetype is in the catalog
Simplest possible trend-following baseline. Valuable as a yardstick to compare more sophisticated strategies against.

## Open questions
- Which exact fast/slow windows? Walk-forward optimization vs. fixed conventional (50/200)?
- Daily bars only, or also higher-frequency variants?
- Long-only, or add the symmetric short side?
- Regime filter (e.g. only trade when SPY > 200-day) — does it help or just curve-fit?
- Position sizing — equal-weight, vol-targeted, or trend-strength-weighted?

## References
- _Add as we collect them._ Classic refs: Faber's "Quantitative Approach to Tactical Asset Allocation"; Covel's *Trend Following*.
