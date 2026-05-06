---
name: SGTrading-ENV-001 repo
description: GitHub repo — source of truth for skills, routines, memory, and strategy docs
type: reference
originSessionId: bdaccfde-f0d6-4dc3-9e8c-03fbd5bfd54d
---
`https://github.com/skelly1313/SGTrading-ENV-001` — main branch is canonical.

Local clone: `C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS\`.

**Key files / folders:**

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | Live catalog of skills + routines with status |
| `CLAUDE.md` | Project context and conventions for Claude |
| `MEMORY/` | Synced mirror of Claude auto-memory |
| `MEMORY/MEMORY.md` | Auto-memory index |
| `ROUTINES/<name>/README.md` | Routine spec and cadence |
| `ROUTINES/<name>/prompt.md` | Runnable prompt for the routine |
| `ROUTINES/<name>/daily/` | Per-run logs |
| `SECRETS.md` | Credential template (placeholders only — no real values) |
| `SECRETS.local.md` | Real credentials (gitignored) |
| `STRATEGIES/` | Formal strategy specs |
| `DOCS/` | Research, decisions, long-form notes |
| `DATA/` | Gitignored market data and backtest cache |

**Memory sync:** `memory-sync` routine pushes local Claude memory → `MEMORY/`. `daily-health-check` flags drift between local and repo, never auto-resolves.
