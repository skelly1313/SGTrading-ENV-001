<#
memory-sync - mirror Claude auto-memory between local dir and repo MEMORY/.

Runs without Claude. Safe to invoke from Task Scheduler or a Claude routine.
PowerShell 5.1+, no external modules.

Exit codes:
  0 = success (in-sync or applied changes)
  1 = conflict detected, no changes applied
  2 = unrecoverable error
#>

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$RepoRoot     = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$MemoryRepo   = Join-Path $RepoRoot 'MEMORY'
$MemoryLocal  = Join-Path $env:USERPROFILE '.claude\projects\C--Users-djske-OneDrive-Desktop-SG-Trading\memory'
$StateFile    = Join-Path $PSScriptRoot 'state.json'
$DailyDir     = Join-Path $PSScriptRoot 'daily'

function Get-Sha256 {
    param([string]$Path)
    (Get-FileHash -Algorithm SHA256 -Path $Path).Hash.ToLower()
}

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

function Load-State {
    if (-not (Test-Path -LiteralPath $StateFile)) {
        return @{ last_sync_utc = $null; files = @{} }
    }
    try {
        $raw = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
        $obj = $raw | ConvertFrom-Json
        $files = @{}
        if ($obj.files) {
            $obj.files.PSObject.Properties | ForEach-Object { $files[$_.Name] = $_.Value }
        }
        return @{ last_sync_utc = $obj.last_sync_utc; files = $files }
    } catch {
        return @{ last_sync_utc = $null; files = @{} }
    }
}

function Save-State {
    param($State)
    $obj = [ordered]@{
        last_sync_utc = $State.last_sync_utc
        files         = $State.files
    }
    $json = $obj | ConvertTo-Json -Depth 5
    Set-Content -LiteralPath $StateFile -Value $json -Encoding UTF8
}

function Classify {
    param($Local, $Repo, $Prev)
    $actions = @{
        local_only    = New-Object System.Collections.Generic.List[string]
        repo_only     = New-Object System.Collections.Generic.List[string]
        local_newer   = New-Object System.Collections.Generic.List[string]
        repo_newer    = New-Object System.Collections.Generic.List[string]
        both_changed  = New-Object System.Collections.Generic.List[string]
        unchanged     = New-Object System.Collections.Generic.List[string]
    }
    $allKeys = @($Local.Keys) + @($Repo.Keys) | Sort-Object -Unique
    foreach ($k in $allKeys) {
        $l = $Local[$k]; $r = $Repo[$k]; $p = $Prev[$k]
        if ($l -and -not $r) { $actions.local_only.Add($k) }
        elseif ($r -and -not $l) { $actions.repo_only.Add($k) }
        elseif ($l -eq $r) { $actions.unchanged.Add($k) }
        else {
            $lChanged = $l -ne $p
            $rChanged = $r -ne $p
            if ($lChanged -and -not $rChanged) { $actions.local_newer.Add($k) }
            elseif ($rChanged -and -not $lChanged) { $actions.repo_newer.Add($k) }
            else { $actions.both_changed.Add($k) }
        }
    }
    return $actions
}

function Copy-Memory {
    param([string]$SrcRoot, [string]$DstRoot, [string]$Rel)
    $src = Join-Path $SrcRoot $Rel
    $dst = Join-Path $DstRoot $Rel
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item -LiteralPath $src -Destination $dst -Force
}

function Refresh-Index {
    $entries = New-Object System.Collections.Generic.List[string]
    Get-ChildItem -LiteralPath $MemoryRepo -Filter *.md -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne 'MEMORY.md' -and $_.Name -ne 'README.md' } |
        Sort-Object Name |
        ForEach-Object {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
            $desc = ''
            $text = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
            if ($text -match '(?s)^---\s*\n(.*?)\n---') {
                $fm = $matches[1]
                foreach ($line in $fm -split "`n") {
                    $line = $line.Trim()
                    if ($line -match '^name:\s*(.+)$') { $name = $matches[1].Trim() }
                    elseif ($line -match '^description:\s*(.+)$') { $desc = $matches[1].Trim() }
                }
            }
            if ($desc) { $entries.Add("- [$name]($($_.Name)) - $desc") }
            else { $entries.Add("- [$name]($($_.Name))") }
        }

    $indexPath = Join-Path $MemoryRepo 'MEMORY.md'
    if ($entries.Count -gt 0) {
        $newBody = ($entries -join "`n") + "`n"
    } else {
        $newBody = "- _(empty - no synced memories yet. The ``memory-sync`` routine will populate this.)_`n"
    }
    $oldBody = if (Test-Path -LiteralPath $indexPath) {
        Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
    } else { '' }
    if ($newBody -ne $oldBody) {
        Set-Content -LiteralPath $indexPath -Value $newBody -Encoding UTF8 -NoNewline
        return $true
    }
    return $false
}

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $stdout = & git -C $RepoRoot @Args 2>&1 | ForEach-Object { "$_" }
        $exit = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldEAP
    }
    return @{ ExitCode = $exit; Output = ($stdout -join "`n").Trim() }
}

function Commit-And-Push {
    param([int]$ChangedCount)
    $diff = Invoke-Git diff --quiet -- 'MEMORY/'
    $diffCached = Invoke-Git diff --cached --quiet -- 'MEMORY/'
    if ($diff.ExitCode -eq 0 -and $diffCached.ExitCode -eq 0) { return $null }

    $stagedBefore = Invoke-Git diff --cached --name-only
    $stagedOutside = $stagedBefore.Output -split "`n" |
        Where-Object { $_ -and -not $_.StartsWith('MEMORY/') }
    if ($stagedOutside) {
        return "REFUSED: pre-staged changes outside MEMORY/: $($stagedOutside -join '; ')"
    }

    Invoke-Git add 'MEMORY/' | Out-Null
    $stagedAfter = Invoke-Git diff --cached --name-only
    $stagedOutside = $stagedAfter.Output -split "`n" |
        Where-Object { $_ -and -not $_.StartsWith('MEMORY/') }
    if ($stagedOutside) {
        Invoke-Git reset HEAD -- 'MEMORY/' | Out-Null
        return "REFUSED: would commit outside MEMORY/: $($stagedOutside -join '; ')"
    }
    $ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm') + 'Z'
    $msg = "memory-sync: $ChangedCount files updated ($ts)"
    $commit = Invoke-Git commit -m $msg
    if ($commit.ExitCode -ne 0) { return "commit failed: $($commit.Output)" }
    $push = Invoke-Git push origin main
    if ($push.ExitCode -ne 0) { return "committed locally, push failed: $($push.Output)" }
    $sha = Invoke-Git rev-parse --short HEAD
    return "committed+pushed $($sha.Output)"
}

function Write-Daily {
    param([string]$Report)
    if (-not (Test-Path -LiteralPath $DailyDir)) {
        New-Item -ItemType Directory -Path $DailyDir -Force | Out-Null
    }
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $log = Join-Path $DailyDir "$today.md"
    Add-Content -LiteralPath $log -Value $Report -Encoding UTF8
}

# --- main ---
try {
    $local = List-MdFiles -Root $MemoryLocal
    $repo  = List-MdFiles -Root $MemoryRepo
    $state = Load-State
    $prev  = $state.files

    if ($local.Count -eq 0 -and $repo.Count -eq 0) {
        Write-Output 'both empty - nothing to do'
        exit 0
    }

    $mode = if ($local.Count -eq 0 -and $repo.Count -gt 0) { 'pull' }
            elseif ($local.Count -gt 0 -and $repo.Count -eq 0) { 'push' }
            else { 'bidirectional' }

    $actions = Classify -Local $local -Repo $repo -Prev $prev

    if ($actions.both_changed.Count -gt 0) {
        $tsHeader = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm') + 'Z'
        $report = "`n## $tsHeader`nmode: $mode`nSTATUS: CONFLICT - both sides changed since last sync`nconflicting files:`n"
        foreach ($p in $actions.both_changed) { $report += "  - $p`n" }
        $report += "No changes applied. Resolve manually.`n"
        Write-Daily -Report $report
        Write-Output $report
        exit 1
    }

    $changed = 0
    if (-not (Test-Path -LiteralPath $MemoryRepo)) {
        New-Item -ItemType Directory -Path $MemoryRepo -Force | Out-Null
    }
    if (-not (Test-Path -LiteralPath $MemoryLocal)) {
        New-Item -ItemType Directory -Path $MemoryLocal -Force | Out-Null
    }

    if (-not $DryRun) {
        foreach ($rel in $actions.local_only)  { Copy-Memory -SrcRoot $MemoryLocal -DstRoot $MemoryRepo -Rel $rel; $changed++ }
        foreach ($rel in $actions.local_newer) { Copy-Memory -SrcRoot $MemoryLocal -DstRoot $MemoryRepo -Rel $rel; $changed++ }
        foreach ($rel in $actions.repo_only)   { Copy-Memory -SrcRoot $MemoryRepo  -DstRoot $MemoryLocal -Rel $rel; $changed++ }
        foreach ($rel in $actions.repo_newer)  { Copy-Memory -SrcRoot $MemoryRepo  -DstRoot $MemoryLocal -Rel $rel; $changed++ }

        if (Refresh-Index) { $changed++ }

        $state.last_sync_utc = (Get-Date).ToUniversalTime().ToString('o')
        $state.files = List-MdFiles -Root $MemoryRepo
        Save-State -State $state
    }

    $commitResult = if ($changed -gt 0 -and -not $DryRun) { Commit-And-Push -ChangedCount $changed } else { $null }

    $tsHeader = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm') + 'Z'
    $lines = @("`n## $tsHeader", "mode: $mode", "changed: $changed")
    foreach ($k in @('local_only','repo_only','local_newer','repo_newer')) {
        if ($actions[$k].Count -gt 0) {
            $lines += "  ${k}: $($actions[$k] -join ', ')"
        }
    }
    if ($commitResult) { $lines += "git: $commitResult" }
    elseif ($changed -eq 0) { $lines += 'git: nothing to commit' }
    elseif ($DryRun) { $lines += 'git: skipped (dry run)' }
    $report = ($lines -join "`n") + "`n"

    if (-not $DryRun) { Write-Daily -Report $report }
    Write-Output $report
    exit 0
}
catch {
    Write-Error "FATAL: $_"
    exit 2
}
