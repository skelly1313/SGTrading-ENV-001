# memory-sync

Mirror Claude's local auto-memory ↔ this repo's `MEMORY/` folder.

## Cadence

Proposed: every 4 hours during the workday — `0 8-20/4 * * 1-5`.
Also runnable on demand.

## Direction

**Default (local → repo):** copy any new or changed files from
`~/.claude/projects/C--Users-djske-OneDrive-Desktop-SG-Trading/memory/`
into `<repo>/MEMORY/`, then commit + push.

**Fallback (repo → local):** if the local memory dir is missing or empty
*and* `MEMORY/` has content, copy from repo to local instead. This handles
cold starts on a fresh machine or when working from cloud Claude.

**Conflict (both changed since last sync):** do not auto-merge. Print a diff
list and stop. Operator picks the winner.

## State tracking

Last successful sync timestamp + per-file SHA-256 stored in
`ROUTINES/memory-sync/state.json` (gitignored — local view of last sync).
A second copy lives in the most recent `daily/<date>.md` for auditability.

## Safety

- Never deletes a file from local just because it's missing from repo (or vice versa) — only adds/updates.
- For deletions: requires explicit operator action (a `tombstone.txt` listing files to remove on next sync).
- Always commits with a clear message: `memory-sync: N files updated (YYYY-MM-DD HH:MM)`.

## Outputs

- Commit + push to `origin/main`.
- Append summary to `daily/<YYYY-MM-DD>.md`.
