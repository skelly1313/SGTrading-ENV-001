<#
notify.ps1 — single-channel notification helper.

Reads Telegram bot creds from SECRETS.local.md (preferred) or SECRETS.md.
Silently no-ops if creds missing — calling code shouldn't fail because
notifications aren't set up yet.

Usage:
  & "<repo>/LIB/notify.ps1" -Message "memory-sync: 0 changed"
  & "<repo>/LIB/notify.ps1" -Message "FAILED: ..." -Level error

Returns $true on send, $false on skip/fail (never throws).
#>

param(
    [Parameter(Mandatory)] [string]$Message,
    [ValidateSet('info','warn','error')] [string]$Level = 'info'
)

$ErrorActionPreference = 'Continue'

function Get-Creds {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    foreach ($name in @('SECRETS.local.md', 'SECRETS.md')) {
        $path = Join-Path $repoRoot $name
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        $token = $null; $chat = $null
        foreach ($line in $text -split "`n") {
            if ($line -match '^\s*\d+\.\s+TELEGRAM_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
            elseif ($line -match '^\s*\d+\.\s+TELEGRAM_CHAT_ID\s*=\s*(.+?)\s*$') { $chat = $matches[1] }
        }
        if ($token -and $chat -and $token -notmatch '^<.*>$' -and $chat -notmatch '^<.*>$') {
            return @{ Token = $token; Chat = $chat; Source = $name }
        }
    }
    return $null
}

$prefix = switch ($Level) { 'error' { '[X]' } 'warn' { '[!]' } default { '[i]' } }
$body = "$prefix SGTrading: $Message"

$creds = Get-Creds
if (-not $creds) {
    Write-Output "notify: no Telegram creds configured, would have sent: $body"
    return $false
}

try {
    $url = "https://api.telegram.org/bot$($creds.Token)/sendMessage"
    $payload = @{
        chat_id = $creds.Chat
        text    = $body
    } | ConvertTo-Json -Compress
    $resp = Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json' -Body $payload -TimeoutSec 10
    if ($resp.ok) {
        return $true
    }
    Write-Output "notify: API rejected: $($resp | ConvertTo-Json -Compress)"
    return $false
}
catch {
    Write-Output "notify: send failed: $_"
    return $false
}
