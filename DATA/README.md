# DATA/

**Gitignored.** Cached market data, backtest outputs, scratch files.

Never commit data files. If you need to share something here, copy it to
`DOCS/research/` with a summary instead.

Suggested layout (created on demand):

```
DATA/
├── bars/          # OHLCV cache by symbol/interval
├── fundamentals/
├── backtests/     # outputs by run-id
└── scratch/
```
