---
name: Real secrets must not go in SECRETS.md
description: SECRETS.md is git-tracked — real credentials belong only in SECRETS.local.md (gitignored)
type: feedback
originSessionId: 6407ad1c-809a-48f7-8628-af819b16a2e3
---
Never write real API keys, tokens, or passwords into `SECRETS.md`. That file is committed to git and pushed to GitHub.

Real credentials always go in `SECRETS.local.md`, which is gitignored.

**Why:** On 2026-05-06 real Alpaca paper-trading credentials were written into `SECRETS.md` and committed. This violates the project's own convention in `CLAUDE.md` and `.gitignore`. The credentials may need rotation if the repo is or becomes public.

**How to apply:** When adding or updating credentials, write only placeholder text (e.g. `<your-alpaca-api-key>`) in `SECRETS.md` and put real values in `SECRETS.local.md`. If the user asks to update `SECRETS.md` with real values, redirect them to `SECRETS.local.md` and explain why.
