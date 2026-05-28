---
name: eod-summary
description: End-of-day report — market close, day narrative, positions/trades/P&L, tomorrow setup
---

End-of-day report for the SG Trading project. Captures market close + daily activity.

Working directory: `C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS`

Target run time: ~16:15 ET, 15 min after US close. All times in output should be ET.

## Sections

### 1. Close
Closing levels for SPX, NDX, DJI, RUT, VIX. % change vs prior close.

### 2. Sectors
S&P sectors — top 3 / bottom 3 by % change.

### 3. Narrative
2–4 bullets on what drove the tape today.

### 4. Positions
Read open positions from broker (Alpaca paper).
If broker integration is not yet wired: write `(not wired)`.

### 5. Trades
Fills from today: symbol, side, qty, avg price, P&L if closed.
If broker integration is not yet wired: write `(not wired)`.

### 6. P&L
Realized + unrealized for today.
If broker integration is not yet wired: write `(not wired)`.

### 7. Tomorrow
Headlines / events to watch for tomorrow's session. 1–3 bullets.

## Output

Append to `ROUTINES/eod-summary/daily/<YYYY-MM-DD>.md`:

```
## <ET timestamp> — eod-summary

### Close
...

### Sectors
...

### Narrative
...

### Positions
...

### Trades
...

### P&L
...

### Tomorrow
...
```

Print to stdout: one-sentence wrap, e.g. "SPX -0.4%, defensives led, tomorrow watch FOMC minutes."

## Safety

- Read-only on broker data — never place or cancel orders here.
- If a data source / broker is unavailable, write `(unavailable)` or `(not wired)` — never fabricate fills, P&L, or positions.
