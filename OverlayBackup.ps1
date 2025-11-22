# === Overlay Backup helpers ===
# Manual/auto backups and restore logic.

if (-not $SourceDir)     { throw "SourceDir is not set." }
if (-not $BackupDir)     { throw "BackupDir is not set." }
if (-not $FilesToBackup) { $FilesToBackup = @("continue.sav","ae_prof.sav","steam_autocloud.vdf") }

function ToDisplayTs {
    $culture = if ($fr) { $fr } else { [System.Globalization.CultureInfo]::InvariantCulture }
    return (Get-Date).ToString("yyyy-MM-dd HH:mm:ss", $culture)
}

function New-BackupFolderName {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    return Join-Path $BackupDir "backup_$stamp"
}

function Copy-FTLFiles($destination) {
    if (-not (Test-Path $destination)) { New-Item -ItemType Directory -Path $destination | Out-Null }
    foreach ($f in $FilesToBackup) {
        $src = Join-Path $SourceDir $f
        $dst = Join-Path $destination $f
        if (Test-Path $src) { Copy-Item -Path $src -Destination $dst -Force }
    }
}

function Load-MostRecentManualToSlot3 {
    $latestFile = $null
    $latestTime = [DateTime]::MinValue

    for ($i=1; $i -le 3; $i++) {
        $src = Join-Path $BackupDir "manual$i.sav"
        if (Test-Path $src) {
            $time = (Get-Item $src).LastWriteTime
            if ($time -gt $latestTime) {
                $latestTime = $time
                $latestFile = $src
            }
        }
    }

    if ($latestFile) {
        $dest = Join-Path $BackupDir "manual3.sav"
        Copy-Item $latestFile $dest -Force
        Copy-Item $latestFile "$SourceDir\prof.sav" -Force
        $OverlayState.Manual[2] = (Get-Date).ToString("HH:mm:ss")
    }
}

function Restore-FTLFiles($source) {
    foreach ($f in $FilesToBackup) {
        $src = Join-Path $source $f
        $dst = Join-Path $SourceDir $f
        if (Test-Path $src) { Copy-Item -Path $src -Destination $dst -Force }
    }
}

function Backup-Manual {
    if ($global:SelectorIndex -notin 1,2,3) { return }
    $folder = Join-Path $BackupDir ("manual_" + $global:SelectorIndex)
    Copy-FTLFiles $folder
}

function Backup-Auto {
    $folder = New-BackupFolderName
    Copy-FTLFiles $folder
    $OverlayState.Auto[0] = ToDisplayTs
}

function Restore-ManualSlot([int]$slot) {
    if ($slot -notin 1,2,3) { return }
    $folder = Join-Path $BackupDir ("manual_" + $slot)
    if (Test-Path $folder) { Restore-FTLFiles $folder }
}

function Restore-AutoLatest {
    if (-not (Test-Path $BackupDir)) { return }
    $latest = Get-ChildItem -Path $BackupDir -Directory -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like "backup_*" } |
              Sort-Object Name -Descending |
              Select-Object -First 1
    if ($latest) { Restore-FTLFiles $latest.FullName }
}
