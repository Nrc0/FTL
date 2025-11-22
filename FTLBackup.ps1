# ============================================================
# FTLBackup.ps1 — Main script based on Application.Run
# ============================================================

# WinForms requires STA (Single Threaded Apartment)
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Write-Host "/!\ Restarting script in STA mode..."
    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        '-NoProfile','-ExecutionPolicy','Bypass','-STA',
        '-File', (Join-Path $PSScriptRoot 'FTLBackup.ps1')
    )
    exit
}

# === CONFIG (global variables) ===
$SourceDir     = "C:\Users\quest\Documents\My Games\FasterThanLight"
$BackupDir     = "$SourceDir\FTL_Backups"
$FilesToBackup = @("continue.sav","ae_prof.sav","steam_autocloud.vdf")

$SteamPath     = "C:\Program Files (x86)\Steam\steam.exe"
$AppID         = "212680"
$GameExe       = "C:\Program Files (x86)\Steam\steamapps\common\FTL Faster Than Light\FTLGame.exe"

# Culture for displayed timestamps
$fr = [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR")

# Ensure backup directory exists
if (-not (Test-Path $BackupDir)) { New-Item -Path $BackupDir -ItemType Directory | Out-Null }

# === Load modules (dot-sourcing) ===
. "$PSScriptRoot\OverlayUI.ps1"
. "$PSScriptRoot\OverlayHelpers.ps1"
. "$PSScriptRoot\OverlayKeys.ps1"
. "$PSScriptRoot\OverlayGame.ps1"
. "$PSScriptRoot\OverlayBackup.ps1"

# === UI and game initialization ===
Display-Overlay
Ensure-GameRunning
Place-OverlayTopRight
Ensure-OverlayTopMost

# Premier lancement : charger uniquement la sauvegarde manuelle la plus récente dans slot 3
Load-MostRecentManualToSlot3
Display-Overlay


# Autosave stopwatch
$autoSW = [Diagnostics.Stopwatch]::StartNew()

# === Main timer (50ms) ===
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50
$timer.Add_Tick({
    # Detect game running
    $proc = Get-Process -Name FTLGame -ErrorAction SilentlyContinue

    if ($proc) {
        # First detection → autosave
        if (-not $OverlayState.SeenGame) {
            Backup-Auto
            $autoSW.Restart()
            $OverlayState.SeenGame = $true
            Display-Overlay
        }
        # Periodic autosave every 10 minutes
        if ($autoSW.Elapsed.TotalMinutes -ge 10) {
            Backup-Auto
            $autoSW.Restart()
            Display-Overlay
        }
    } else {
        # Game closed → stop overlay
        if ($OverlayState.SeenGame) {
            Write-Host "FTL closed, shutting down overlay..."
            $timer.Stop()
            $form.Close()
        }
    }

    # Input and overlay maintenance
    Handle-ArrowRepeat     # Up/Down navigation
    Handle-NumKeys         # Num0 save, Num1/2/3/9 direct restore, Num+ load selected
    Handle-Enter           # optional quick save (Enter)
    Place-OverlayTopRight
    Ensure-OverlayTopMost
})
$timer.Start()

# === WinForms application loop ===
[System.Windows.Forms.Application]::Run($form)

# === Cleanup ===
try {
    if ($timer) { $timer.Stop(); $timer.Dispose() }
    if ($form -and -not $form.IsDisposed) { $form.Dispose() }
} catch { }
exit
