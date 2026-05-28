<#
daily-health-check - verify the SKILLS scaffold is healthy.

Read-only. Reports drift; never fixes. Notifies via LIB/notify.ps1 when
configured. Safe to run on demand or from Task Scheduler.

Exit codes:
  0 = ALL CLEAR
  1 = drift detected (non-fatal - operator should review)
  2 = fatal error
#>

param([switch]$NoNotify)

$ErrorActionPreference = 'Stop'

$RepoRoot     = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$DailyDir     = Join-Path $PSScriptRoot 'daily'
$MemoryRepo   = Join-Path $RepoRoot 'MEMORY'
$MemoryLocal  = Join-Path $env:USERPROFILE '.claude\projects\C--Users-djske-OneDrive-Desktop-SG-Trading\memory'

# Routine name -> Windows scheduled task name
$ExpectedTasks = @{
    'memory-sync'        = 'SGTrading-MemorySync'
    'daily-health-check' = 'SGTrading-HealthCheck'
}

# Routines that don't need a scheduled task (proposed / on-demand)
$SkipTaskCheck = @('archive')

$Findings = New-Object System.Collections.Generic.List[hashtable]

function Add-Finding {
    param([string]$Check, [string]$Status, [string]$Detail)
    $Findings.Add(@{ Check=$Check; Status=$Status; Detail=$Detail })
}

function Get-Sha256 { param([string]$Path) (Get-FileHash -Algorithm SHA256 -Path $Path).Hash.ToLower() }

function List-MdFiles {
    param([string]$Root)
    $result = @{}
    if (-not (Test-Path -LiteralPath $Root)) { return $result }
    $rootResolved = (Resolve-Path -LiteralPath $Root).Path
    Get-ChildItem -LiteralPath $rootResolved -Filter *.md -Recurse -File |
        ForEach-Object {
            $rel = $_.FullName.Substring($rootResolved.Length).TrimStart('\','/').Replace('\','/')
            if ($rel -match '(^|/)\.[^/]') { return }
            $result[$rel] = Get-Sha256 -Path $_.FullName
        }
    return $result
}

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & git -C $RepoRoot @Args 2>&1 | ForEach-Object { "$_" }
        $exit = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldEAP
    }
    return @{ ExitCode = $exit; Output = ($out -join "`n").Trim() }
}

# --- Check 1: Secrets ---
function Check-Secrets {
    $localPath = Join-Path $RepoRoot 'SECRETS.local.md'
    $tmplPath  = Join-Path $RepoRoot 'SECRETS.md'

    $source = if (Test-Path -LiteralPath $localPath) { $localPath }
              elseif (Test-Path -LiteralPath $tmplPath) { $tmplPath }
              else { $null }

    if (-not $source) {
        Add-Finding 'Secrets file present' 'DRIFT' 'No SECRETS.local.md or SECRETS.md'
        return
    }

    $isTemplate = ($source -eq $tmplPath)
    $text = Get-Content -LiteralPath $source -Raw -Encoding UTF8
    $issues = @()
    $keysFound = 0
    foreach ($line in $text -split "`n") {
        if ($line -match '^\s*\d+\.\s+(\w+)\s*=\s*(.+?)\s*$') {
            $keysFound++
            $key = $matches[1]
            $val = $matches[2]
            if (-not $val -or $val -match '^<.*>$' -or $val -match '(?i)your-|example|placeholder|<bot-token>|<chat-id>|<token>|<username>') {
                $issues += "$key=placeholder"
            }
        }
    }

    $sourceName = Split-Path -Leaf $source
    if ($keysFound -eq 0) {
        Add-Finding 'Secrets values populated' 'DRIFT' "$sourceName has no key=value lines"
    } elseif ($issues) {
        Add-Finding 'Secrets values populated' 'DRIFT' "$sourceName has placeholders: $($issues -join ', ')"
    } else {
        Add-Finding 'Secrets values populated' 'OK' "$sourceName ($keysFound keys)"
    }

    # Convention: if SECRETS.local.md exists AND SECRETS.md has real-looking values, that's drift.
    if (Test-Path -LiteralPath $localPath) {
        $tmplText = Get-Content -LiteralPath $tmplPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($tmplText) {
            $realInTmpl = $false
            foreach ($line in $tmplText -split "`n") {
                if ($line -match '^\s*\d+\.\s+\w+\s*=\s*(.+?)\s*$') {
                    $v = $matches[1]
                    if ($v -and $v -notmatch '^<.*>$' -and $v -notmatch '(?i)your-|example|placeholder|bot-token|chat-id') {
                        $realInTmpl = $true; break
                    }
                }
            }
            if ($realInTmpl) {
                Add-Finding 'SECRETS.md is template-only' 'DRIFT' 'SECRETS.md contains real-looking values; move them to SECRETS.local.md'
            } else {
                Add-Finding 'SECRETS.md is template-only' 'OK' 'placeholders only'
            }
        }
    }

    # ALPACA_BASE_URL sanity
    foreach ($line in $text -split "`n") {
        if ($line -match '^\s*\d+\.\s+ALPACA_BASE_URL\s*=\s*(.+?)\s*$') {
            $url = $matches[1]
            if ($url -match 'paper-api\.alpaca\.markets') {
                Add-Finding 'ALPACA_BASE_URL points at paper' 'OK' $url
            } elseif ($url -match 'api\.alpaca\.markets') {
                Add-Finding 'ALPACA_BASE_URL points at paper' 'WARN' "live URL - confirm intentional ($url)"
            } else {
                Add-Finding 'ALPACA_BASE_URL points at paper' 'DRIFT' "unrecognized: $url"
            }
        }
    }
}

# --- Check 2: Routines vs scheduled tasks ---
function Check-Routines {
    $routineDir = Join-Path $RepoRoot 'ROUTINES'
    if (-not (Test-Path -LiteralPath $routineDir)) {
        Add-Finding 'ROUTINES folder present' 'DRIFT' 'missing'
        return
    }
    $routines = Get-ChildItem -LiteralPath $routineDir -Directory |
        Where-Object { $_.Name -notin $SkipTaskCheck }

    foreach ($r in $routines) {
        $name = $r.Name
        $readme = Join-Path $r.FullName 'README.md'
        if (-not (Test-Path -LiteralPath $readme)) {
            Add-Finding "Routine: $name" 'DRIFT' 'no README.md'
            continue
        }

        if ($ExpectedTasks.ContainsKey($name)) {
            $taskName = $ExpectedTasks[$name]
            $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if (-not $task) {
                Add-Finding "Routine: $name" 'DRIFT' "scheduled task '$taskName' not registered"
            } elseif ($task.State -eq 'Disabled') {
                Add-Finding "Routine: $name" 'DRIFT' "task '$taskName' is disabled"
            } else {
                $info = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction SilentlyContinue
                $next = if ($info) { $info.NextRunTime.ToString('yyyy-MM-dd HH:mm') } else { '?' }
                Add-Finding "Routine: $name" 'OK' "task ready, next run $next"
            }
        } else {
            Add-Finding "Routine: $name" 'INFO' 'no scheduled task expected (proposed/on-demand)'
        }
    }
}

# --- Check 3: Memory parity ---
function Check-MemoryParity {
    $local = List-MdFiles -Root $MemoryLocal
    $repo  = List-MdFiles -Root $MemoryRepo
    if ($local.Count -eq 0 -and $repo.Count -eq 0) {
        Add-Finding 'Memory: local vs repo' 'OK' 'both empty'
        return
    }
    $localOnly = @(); $repoOnly = @(); $differ = @()
    $allKeys = @($local.Keys) + @($repo.Keys) | Sort-Object -Unique
    foreach ($k in $allKeys) {
        if ($local[$k] -and -not $repo[$k]) { $localOnly += $k }
        elseif ($repo[$k] -and -not $local[$k]) { $repoOnly += $k }
        elseif ($local[$k] -ne $repo[$k]) { $differ += $k }
    }
    if (-not $localOnly -and -not $repoOnly -and -not $differ) {
        Add-Finding 'Memory: local vs repo' 'OK' "$($local.Count) files in sync"
    } else {
        $bits = @()
        if ($localOnly) { $bits += "LOCAL_ONLY=$($localOnly.Count)" }
        if ($repoOnly)  { $bits += "REPO_ONLY=$($repoOnly.Count)" }
        if ($differ)    { $bits += "DIFFER=$($differ.Count)" }
        $status = if ($differ) { 'CONFLICT' } else { 'DRIFT' }
        Add-Finding 'Memory: local vs repo' $status ($bits -join ', ')
    }
}

# --- Check 4: Repo hygiene ---
function Check-RepoHygiene {
    $gi = Join-Path $RepoRoot '.gitignore'
    if (-not (Test-Path -LiteralPath $gi)) {
        Add-Finding 'Repo hygiene: .gitignore' 'DRIFT' 'missing'
    } else {
        $text = Get-Content -LiteralPath $gi -Raw -Encoding UTF8
        $required = @('SECRETS.local.md', '.DS_Store', '.claude/', 'DATA/')
        $missing = $required | Where-Object { $text -notmatch [regex]::Escape($_) }
        if ($missing) {
            Add-Finding 'Repo hygiene: .gitignore' 'DRIFT' "missing entries: $($missing -join ', ')"
        } else {
            Add-Finding 'Repo hygiene: .gitignore' 'OK' 'required entries present'
        }
    }

    # No tracked SECRETS.local.md or *.env
    $tracked = Invoke-Git ls-files
    $leaks = $tracked.Output -split "`n" | Where-Object {
        $_ -eq 'SECRETS.local.md' -or $_ -match '\.env$' -or $_ -match '/credentials\.env$' -or $_ -match '^DATA/' -and $_ -ne 'DATA/README.md'
    }
    if ($leaks) {
        Add-Finding 'Repo hygiene: no leaked secrets/data' 'DRIFT' "tracked: $($leaks -join ', ')"
    } else {
        Add-Finding 'Repo hygiene: no leaked secrets/data' 'OK' 'clean'
    }

    # Working tree clean? (informational)
    $status = Invoke-Git status --porcelain
    if ($status.Output) {
        $count = ($status.Output -split "`n").Count
        Add-Finding 'Git working tree' 'INFO' "$count files modified/untracked"
    } else {
        Add-Finding 'Git working tree' 'OK' 'clean'
    }
}

# --- Run ---
try {
    Check-Secrets
    Check-Routines
    Check-MemoryParity
    Check-RepoHygiene
} catch {
    Write-Error "FATAL: $_"
    exit 2
}

# --- Build report ---
$now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm') + 'Z'
$drift = @($Findings | Where-Object { $_.Status -in @('DRIFT','CONFLICT') })
$warn  = @($Findings | Where-Object { $_.Status -eq 'WARN' })

$header = if ($drift.Count -eq 0 -and $warn.Count -eq 0) {
    "ALL CLEAR - skills, routines, memory, hygiene aligned."
} elseif ($drift.Count -gt 0) {
    "ATTENTION: $($drift.Count) drift item(s)" + $(if ($warn.Count) { ", $($warn.Count) warning(s)" } else { '' })
} else {
    "OK with $($warn.Count) warning(s)"
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("`n## $now")
$lines.Add($header)
$lines.Add('')
$lines.Add('| Check | Status | Detail |')
$lines.Add('|---|---|---|')
foreach ($f in $Findings) {
    $detail = ($f.Detail -replace '\|','\|')
    $row = '| ' + $f.Check + ' | ' + $f.Status + ' | ' + $detail + ' |'
    $lines.Add($row)
}

$report = ($lines -join "`n") + "`n"

# --- Persist ---
if (-not (Test-Path -LiteralPath $DailyDir)) {
    New-Item -ItemType Directory -Path $DailyDir -Force | Out-Null
}
$today = (Get-Date).ToString('yyyy-MM-dd')
Add-Content -LiteralPath (Join-Path $DailyDir "$today.md") -Value $report -Encoding UTF8

Write-Output $report

# --- Notify ---
if (-not $NoNotify) {
    $notifyScript = Join-Path $RepoRoot 'ROUTINES\notify\notify.ps1'
    if (Test-Path -LiteralPath $notifyScript) {
        $level = if ($drift.Count -gt 0) { 'error' } elseif ($warn.Count -gt 0) { 'warn' } else { 'info' }
        $totalChecks = $Findings.Count
        $driftCount  = $drift.Count
        $warnCount   = $warn.Count
        if ($driftCount -eq 0 -and $warnCount -eq 0) {
            $oneLine = "health-check ALL CLEAR - $totalChecks checks"
        } else {
            $names = ($drift + $warn | ForEach-Object { $_.Check }) -join ', '
            $oneLine = "health-check: $driftCount drift / $warnCount warn - $names"
        }
        & $notifyScript -Message $oneLine -Level $level | Out-Null
    }
}

if ($drift.Count -gt 0) { exit 1 } else { exit 0 }
