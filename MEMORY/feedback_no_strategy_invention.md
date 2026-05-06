---
name: Don't invent trading strategy details
description: User wants scaffold first; never fabricate strategy rules, indicators, or broker choices
type: feedback
originSessionId: bdaccfde-f0d6-4dc3-9e8c-03fbd5bfd54d
---
Do not write concrete trading rules, indicator parameters, broker selections,
or risk thresholds without explicit user input.

**Why:** user said on 2026-05-06 they haven't gone far into details or
strategy yet. Hallucinated specifics in a trading context can cause real
financial loss if they leak into code or get treated as decisions later.

**How to apply:** when filling in templates or specs, leave clearly-marked
placeholders (`<TBD>`, `# Open question`) instead of guessing. Ask before
adding numbers, tickers, or rules. Infrastructure work (sync, routines,
backtester scaffolding) doesn't need this caution — only the strategy logic
itself.
