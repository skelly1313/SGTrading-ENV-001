# BOOTSTRAP

Setup steps for a fresh Windows machine. ~10 minutes start-to-finish.

## 0. Prerequisites

- **Git for Windows** - https://git-scm.com/download/win
- **PowerShell 5.1+** (built into Windows 10/11)
- **GitHub auth** - either Git Credential Manager (default with Git for Windows) or a personal access token

## 1. Clone the repo

```powershell
cd "$env:USERPROFILE\OneDrive\Desktop"
mkdir "SG Trading" -ErrorAction SilentlyContinue
cd "SG Trading"
git clone https://github.com/skelly1313/SGTrading-ENV-001.git SKILLS
cd SKILLS
```

## 2. PowerShell execution policy

The sync and health-check scripts won't run under default policy. Either:

- **Per-invocation (safe, what scheduled tasks use):**
  No setup needed - the task triggers `powershell.exe -ExecutionPolicy Bypass -File ...`.

- **Allow current user (more convenient for ad-hoc runs):**
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

## 3. Populate `SECRETS.local.md`

Real credentials live here, never in tracked `SECRETS.md`. Create the file (it's gitignored):

```powershell
Copy-Item SECRETS.md SECRETS.local.md
notepad SECRETS.local.md
```

Replace placeholders with real values. At minimum, for current scope:

```
### ALPACA SECRETS (Paper Trading)

1. ALPACA_API_KEY = <your-key>
2. ALPACA_SECRET_KEY = <your-secret>
3. ALPACA_BASE_URL = https://paper-api.alpaca.markets

### TELEGRAM SECRETS

1. TELEGRAM_BOT_TOKEN = <bot-token>
2. TELEGRAM_CHAT_ID = <chat-id>
```

Telegram is optional - skip it and notifications silently no-op. Setup steps for Telegram bot are in [`LIB/README.md`](LIB/README.md).

## 4. First memory sync

This populates `MEMORY/` from your local Claude memory (or vice versa on a fresh machine):

```powershell
powershell -ExecutionPolicy Bypass -File ROUTINES\memory-sync\sync.ps1
```

Expected output: `mode: pull` (fresh machine pulling memory down) or `mode: push` (existing machine seeding repo).

## 5. First health check

```powershell
powershell -ExecutionPolicy Bypass -File ROUTINES\daily-health-check\check.ps1 -NoNotify
```

Should print `ALL CLEAR` once everything is set up. Drift items are normal during bootstrap (e.g. scheduled tasks not yet registered - next step).

## 6. Register scheduled tasks

Both routines run automatically once registered.

```powershell
# memory-sync: weekdays at 8am, 12pm, 4pm, 8pm
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS\ROUTINES\memory-sync\sync.ps1"'
$triggers = @()
foreach ($h in 8,12,16,20) {
    $triggers += New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At ([datetime]::Today.AddHours($h))
}
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
Register-ScheduledTask -TaskName 'SGTrading-MemorySync' -Action $action -Trigger $triggers -Settings $settings -Principal $principal -Force

# daily-health-check: weekdays at 9am
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Users\djske\OneDrive\Desktop\SG Trading\SKILLS\ROUTINES\daily-health-check\check.ps1"'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At ([datetime]::Today.AddHours(9))
Register-ScheduledTask -TaskName 'SGTrading-HealthCheck' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
```

Path is hard-coded - if your repo is elsewhere, edit before running.

Verify:

```powershell
Get-ScheduledTask -TaskName 'SGTrading-*' | Select-Object TaskName,State
```

Both should show `Ready`.

## 7. Done

Test the full chain: trigger a sync manually and confirm a notification arrives (if Telegram is configured).

```powershell
powershell -ExecutionPolicy Bypass -File ROUTINES\daily-health-check\check.ps1
```

## Routine maintenance

- **View next run times:** `Get-ScheduledTaskInfo -TaskName 'SGTrading-MemorySync'`
- **Run a routine on demand:** open Task Scheduler GUI, right-click task, Run. Or invoke the script directly.
- **Disable temporarily:** `Disable-ScheduledTask -TaskName 'SGTrading-MemorySync'`
- **Remove entirely:** `Unregister-ScheduledTask -TaskName 'SGTrading-MemorySync' -Confirm:$false`

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `cannot be loaded because running scripts is disabled` | execution policy | use `-ExecutionPolicy Bypass` per-invocation, or set `RemoteSigned` for `CurrentUser` (step 2) |
| `memory-sync: REFUSED: pre-staged changes outside MEMORY/` | unrelated git changes staged | unstage them: `git reset HEAD <file>`, re-run sync |
| `health-check: scheduled task not registered` | step 6 not run | run step 6 |
| Notifications never arrive | Telegram creds wrong/missing | re-check `SECRETS.local.md`, run `powershell LIB\notify.ps1 -Message test` |
| `Memory: CONFLICT DIFFER=N` | local and repo both changed same file | inspect diffs, pick winner manually, re-run sync |
