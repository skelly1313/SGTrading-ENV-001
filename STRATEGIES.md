# STRATEGIES (project-level)

Catalog of trading strategies for SG Trading.

Mirrors the `MEMORY.md` ↔ `MEMORY/` pattern:

- This file is the **index** — one row per strategy, status at a glance.
- Per-strategy folders live in [`STRATEGIES/`](STRATEGIES/), each with a `spec.md`.

---

## Catalog

| Strategy | Class | Universe | Status | Last reviewed |
| --- | --- | --- | --- | --- |
| [moving-average-crossover](STRATEGIES/moving-average-crossover/spec.md) | trend-following | _TBD_ | example | 2026-05-06 |
| [mean-reversion-rsi](STRATEGIES/mean-reversion-rsi/spec.md) | mean-reversion | _TBD_ | example | 2026-05-06 |
| [opening-range-breakout](STRATEGIES/opening-range-breakout/spec.md) | breakout / intraday | _TBD_ | example | 2026-05-06 |

### Status values

- `example` — scaffold/template; archetype is real but parameters are placeholders. **Not** a decided strategy.
- `draft` — user has filled in the universe, signal, and risk for a real candidate.
- `paper-trading` — running on Alpaca paper account.
- `live` — running with real capital.
- `retired` — no longer in use; kept for reference.

A spec is **not** `draft` until the user has replaced every `<TBD>` with a real choice.

## Layout

```
STRATEGIES/
├── README.md                          ← folder conventions
├── <strategy-name>/
│   ├── spec.md                        ← formal spec (entry/exit/sizing/risk)
│   ├── notes.md                       ← scratchpad: thesis, open questions, refs
│   └── backtests/                     ← backtest outputs (gitignored if large)
```

Half-formed ideas live as `notes.md` inside the strategy's own folder from day one
(use `status: example` or `draft` while the spec is incomplete).

## Conventions

- One folder per strategy, kebab-case name (`mean-reversion-rsi`, not `MeanReversionRSI`).
- The folder name must match the `name:` frontmatter in `spec.md`.
- Every spec has all six sections filled (Universe, Signal, Sizing, Risk, Backtest, Known weaknesses) — `<TBD>` is fine, missing sections are not.
- Risk caps in `spec.md` must agree with portfolio-wide caps once those are set globally.
- Backtest results: store the summary in `backtests/<YYYY-MM-DD>-<note>.md`, raw data in `DATA/backtests/` (gitignored).

## Change log

- **2026-05-06** — initial catalog scaffolded with three example archetypes.
