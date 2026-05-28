---
name: AGENTS.md vs CLAUDE.md roles
description: AGENTS.md is index-only; project context and decisions live in CLAUDE.md
type: feedback
originSessionId: 70d4bf60-75a2-423c-ba02-01f499e3e70e
---
`AGENTS.md` is a clean index — only the Skills table and Routines tables (Local / Cloud). No prose, no management instructions, no decisions, no candidate lists.

`CLAUDE.md` is where prose belongs: mission, conventions, decisions, open questions, file-role definitions.

**Why:** user pushed back twice when AGENTS.md grew explanatory text and a Decisions section ("this is getting convoluted... should be simply skills and routines"). They want AGENTS.md scannable in 5 seconds.

**How to apply:** when adding info, ask "is this an entry in a table?" — if yes, AGENTS.md; if it's prose, context, or rationale, CLAUDE.md (or `DOCS/decisions/` for long-form ADRs). Never bloat AGENTS.md with explanatory paragraphs.
