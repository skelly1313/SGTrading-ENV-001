# `<skill-name>` (template)

Copy this file, rename it, and fill in the placeholders.

> The runnable copy of this skill lives at `~/.claude/skills/<skill-name>/SKILL.md`
> (or wherever your agent loads skills from). This file in the project folder
> is the human-friendly mirror — keep them in sync.

## Triggers

When this skill should activate. Examples: "user asks about `<topic>`", "user
references an identifier matching `<pattern>`".

## Interfaces

| Interface | Use when |
| --- | --- |
| `<CLI / SDK / REST>` | <when this is the right path> |
| `<dedicated MCP / connector>` | <when this is the right path> |

## Auth

- Credentials file: `~/.claude/skills/<skill-name>/credentials.env` (chmod 600).
- Exports: `<KEY_1>`, `<KEY_2>`, …
- Source of truth: the matching block in [`SECRETS.md`](SECRETS.md).

## Decision tree (quick reference)

- "<common ask>" → <one-line procedure>
- "<another common ask>" → <one-line procedure>

## Destructive actions

Always require explicit user confirmation before running:

- `<destructive op 1>`
- `<destructive op 2>`
