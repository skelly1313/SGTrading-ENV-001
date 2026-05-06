---
name: SG Trading project
description: Trading-bot project — Alpaca paper broker chosen, routines scaffolded, strategy undefined
type: project
originSessionId: bdaccfde-f0d6-4dc3-9e8c-03fbd5bfd54d
---
Building a trading bot from scratch. Current state as of 2026-05-06:

**Decided:**
- Broker: Alpaca, paper trading (`paper-api.alpaca.markets`)
- Routines scaffolded: `memory-sync`, `daily-health-check`
- Skills catalog: `AGENTS.md` — tracks status (not started / scaffold / beyond) for every skill

**Not yet decided:**
- Strategy (entry, exit, sizing, risk)
- Market data source (Alpaca bundled vs Polygon / Databento / Tiingo)
- Language / runtime (Python? Node? Both?)
- Asset universe (equities only? +crypto via Alpaca?)
- Capital and risk caps

**Why:** user said on 2026-05-06 they haven't gone into strategy details yet; scaffold first.

**How to apply:** don't invent strategy specifics, indicators, or risk thresholds. Alpaca credentials exist but are paper-only. Consult `AGENTS.md` before assuming what's built — it's the live skill-status catalog.
