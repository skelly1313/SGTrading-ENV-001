---
name: market-open-scan
description: Pre-market AM brief — index futures, movers, calendar, overnight headlines
---

Pre-market brief for the SG Trading project. Capture factual market context — no strategy interpretation, no buy/sell calls.

Working directory: `C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS`

Target run time: ~08:00 ET, ~90 min before US open. All times in output should be ET.

## Sections

### 1. Index futures (overnight → now)
For each of ES, NQ, YM, RTY: last, % change overnight, range.

### 2. Pre-market movers
Top 5 % gainers and top 5 % losers in pre-market with volume > 100k. One-line catalyst per name when obvious.

### 3. Economic calendar (today, US)
Scheduled releases with time (ET), prior, consensus when available. Flag high-impact items.

### 4. Earnings (today)
Notable pre-market and post-close releases — large caps and high-IV names. Name + time slot only.

### 5. Overnight headlines
3–5 bullets from Asia/Europe sessions or US after-hours that may move the open.

### 6. Watchlist
Read `STRATEGIES/<each-strategy>/watchlist.md` if present. If none exist, write `(no active watchlists)`.

## Output

Append to `ROUTINES/market-open-scan/daily/<YYYY-MM-DD>.md`:

```
## <ET timestamp> — market-open-scan

### Index futures
...

### Pre-market movers
...

### Economic calendar
...

### Earnings
...

### Headlines
...

### Watchlist
...
```

Print to stdout: one-sentence open posture, e.g. "Futures up modestly, CPI at 8:30 ET is the key event."

## Safety

- Read public market data only. No orders. No backtests.
- If a data source is unavailable, write `(unavailable)` for that section — never hallucinate values.
- Don't interpret as buy/sell recommendations. Facts only.
