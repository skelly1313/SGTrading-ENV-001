# MEMORY/

Mirror of Claude's auto-memory for this project.

**Local source:** `~/.claude/projects/C--Users-djske-OneDrive-Desktop-SG-Trading/memory/`
**Repo mirror:** this folder.

## Sync model

1. **Local-first writes (default).** When working from this machine, Claude writes to the local memory dir. The `memory-sync` routine pushes new/changed files into this folder and commits them.
2. **Cloud-first writes (fallback).** When working without access to the local dir (other machine, cloud Claude), write memory files directly to this folder. They become the new truth on next sync.
3. **Reconciliation.** `daily-health-check` compares local vs repo. If both changed since last sync, it flags the conflict — operator decides. No silent overwrites.

## Layout

Same structure as Claude's memory dir:

```
MEMORY/
├── MEMORY.md          # index — one line per memory file
├── user_*.md          # facts about the user
├── feedback_*.md      # corrections / validated approaches
├── project_*.md       # current initiatives, decisions, deadlines
└── reference_*.md     # pointers to external systems
```

Each memory file uses the standard frontmatter:

```markdown
---
name: <short name>
description: <one-line, used to gauge relevance>
type: user | feedback | project | reference
---

<body>
```

## What goes here vs. project-level MEMORY.md

- **This folder:** Claude's auto-memory entries — facts you want available across future conversations.
- **`../MEMORY.md`:** project-level conventions, sources of truth, cross-cutting decisions.

If unsure: a fact about *how Claude should behave* or *what the user prefers* → here. A fact about *the repo's structure or rules* → `../MEMORY.md`.
