# LIB/

Small reusable helpers shared by routines and skills.

## `notify.ps1`

Single-channel notification helper (Telegram for now). Reads creds from
`SECRETS.local.md` or `SECRETS.md`. Silently no-ops if creds are missing —
callers shouldn't fail just because notifications aren't wired up yet.

### Setup

1. **Create a bot:** message [@BotFather](https://t.me/BotFather) on Telegram, run `/newbot`, follow prompts. Save the token.
2. **Get your chat ID:** send any message to your new bot, then visit `https://api.telegram.org/bot<TOKEN>/getUpdates` and find `"chat":{"id":<NUMBER>`.
3. **Add to `SECRETS.local.md`:**
   ```
   ### TELEGRAM SECRETS

   1. TELEGRAM_BOT_TOKEN = <token>
   2. TELEGRAM_CHAT_ID = <chat-id>
   ```
4. **Test:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File "LIB/notify.ps1" -Message "test"
   ```

### Calling from another script

```powershell
$ok = & "$PSScriptRoot\..\..\LIB\notify.ps1" -Message "$summary" -Level info
```

Levels: `info` (default), `warn`, `error` — emoji prefix only, no behavior change.
