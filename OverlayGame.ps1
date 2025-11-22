# === Overlay Game helpers ===
# Launch FTL via Steam and ensure the game process is running, then maximize its window.

if (-not $SteamPath) { $SteamPath = "C:\Program Files (x86)\Steam\steam.exe" }
if (-not $AppID)     { $AppID     = "212680" }

# Win32 API for window manipulation
if (-not ("Win32Window" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Win32Window {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@
}

# Constants for ShowWindow
$SW_MAXIMIZE = 3

function Start-FTL {
    Start-Process "steam://rungameid/$AppID" | Out-Null
}

function Ensure-GameRunning {
    $tries = 0
    while ($true) {
        $proc = Get-Process -Name "FTLGame" -ErrorAction SilentlyContinue
        if ($proc) {
            # Maximize the game window once detected
            $hWnd = $proc.MainWindowHandle
            if ($hWnd -ne [IntPtr]::Zero) {
                [Win32Window]::ShowWindow($hWnd, $SW_MAXIMIZE) | Out-Null
                [Win32Window]::SetForegroundWindow($hWnd) | Out-Null
            }
            break
        }
        if ($tries -eq 0) { Start-FTL }
        Start-Sleep -Milliseconds 500
        $tries++
        if ($tries -gt 60) { break } # ~30s max wait
    }
}
