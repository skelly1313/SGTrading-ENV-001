---
name: SGTrading-ENV-001 repo
description: GitHub repo serving as source of truth for skills, routines, memory
type: reference
originSessionId: bdaccfde-f0d6-4dc3-9e8c-03fbd5bfd54d
---
`https://github.com/skelly1313/SGTrading-ENV-001` — main branch is canonical.

Local clone: `C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS\`.

Holds: project CLAUDE.md, AGENTS.md, MEMORY.md (project-level), MEMORY/
(synced auto-memory mirror), DOCS/, STRATEGIES/, ROUTINES/, DATA/ (gitignored).

Memory sync model: `memory-sync` routine pushes local Claude memory →
`MEMORY/` in repo. On a fresh machine or cloud Claude, writes go to repo
and sync pulls them down. `daily-health-check` flags drift, never
auto-resolves.
