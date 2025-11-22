# === Overlay Helpers ===

if (-not $OverlayState) {
    $OverlayState = @{
        Manual   = @($null,$null,$null)
        Auto     = @($null,$null,$null)
        SeenGame = $false
    }
}

if (-not $global:SelectorIndex) { $global:SelectorIndex = 1 }

function Show-OrDash {
    param([string]$s)
    if ([string]::IsNullOrWhiteSpace($s)) { "—" } else { $s }
}

function Show-ReloadConfirmation {
    param([string]$slotName)

    # Message temporaire en cyan
    $lblLine0.Text = "✔ Reloaded slot $slotName"
    $lblLine0.ForeColor = [Drawing.Color]::Cyan

    # Après 1 seconde, revenir à la ligne d’aide normale
    Start-Sleep -Milliseconds 1000
    $lblLine0.Text = "[↑/↓] Select | [0]: Save | [+]: Load"
    $lblLine0.ForeColor = [Drawing.Color]::LightSkyBlue
}

function Display-Overlay {
    $prefix1 = if ($global:SelectorIndex -eq 1) { "> " } else { "  " }
    $prefix2 = if ($global:SelectorIndex -eq 2) { "> " } else { "  " }
    $prefix3 = if ($global:SelectorIndex -eq 3) { "> " } else { "  " }
    $prefix9 = if ($global:SelectorIndex -eq 9) { "> " } else { "  " }

    $lblLine1.Text = $prefix1 + "[1] : " + (Show-OrDash $OverlayState.Manual[0])
    $lblLine2.Text = $prefix2 + "[2] : " + (Show-OrDash $OverlayState.Manual[1])
    $lblLine3.Text = $prefix3 + "[3] : " + (Show-OrDash $OverlayState.Manual[2])
    $lblAuto.Text  = $prefix9 + "Auto-save: " + (Show-OrDash $OverlayState.Auto[0])
}

function Place-OverlayTopRight {
    $screen=[System.Windows.Forms.Screen]::PrimaryScreen
    $posX=$screen.WorkingArea.Right-$form.Width-10
    $posY=$screen.WorkingArea.Top+35
    $form.Location=New-Object System.Drawing.Point -ArgumentList $posX,$posY
}


if (-not ("ZOrder" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class ZOrder {
    public const int SWP_NOSIZE=0x0001;
    public const int SWP_NOMOVE=0x0002;
    public static readonly IntPtr HWND_TOPMOST=new IntPtr(-1);
    [DllImport("user32.dll",SetLastError=true)]
    public static extern bool SetWindowPos(IntPtr hWnd,IntPtr hWndInsertAfter,int X,int Y,int cx,int cy,uint uFlags);
}
"@
}

function Ensure-OverlayTopMost {
    if ($form -and -not $form.IsDisposed -and $form.Handle -ne [IntPtr]::Zero) {
        [ZOrder]::SetWindowPos(
            $form.Handle,
            [ZOrder]::HWND_TOPMOST,
            0,0,0,0,
            [ZOrder]::SWP_NOMOVE -bor [ZOrder]::SWP_NOSIZE
        ) | Out-Null
    }
}
