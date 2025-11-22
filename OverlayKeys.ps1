# === Overlay Keys ===
# Key handling for navigation and actions.

# Win32 polling: GetAsyncKeyState
if (-not ("KeyPoll" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class KeyPoll {
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
}
"@
}

# Keypad and arrows
$VK = @{
    'Num0'   = 0x60   # keypad 0 → save selected
    'Num1'   = 0x61   # keypad 1 → restore slot 1
    'Num2'   = 0x62   # keypad 2 → restore slot 2
    'Num3'   = 0x63   # keypad 3 → restore slot 3
    'Num9'   = 0x69   # keypad 9 → restore latest auto
    'NumAdd' = 0x6B   # keypad + → load selected
    'Enter'  = 0x0D   # optional: quick save (same as Num0)
    'Up'     = 0x26
    'Down'   = 0x28
}

$KeyDown = @{}
foreach ($k in $VK.Keys) { $KeyDown[$k] = $false }

$RepeatState = @{
    'Up'   = @{ Last=[DateTime]::MinValue; InitialMs=120; RepeatMs=70; Active=$false }
    'Down' = @{ Last=[DateTime]::MinValue; InitialMs=120; RepeatMs=70; Active=$false }
}

function KeyPressed($name) {
    return (([KeyPoll]::GetAsyncKeyState($VK[$name]) -band 0x8000) -ne 0)
}

function Handle-ArrowRepeat {
    foreach ($arrow in @('Up','Down')) {
        $isDown = KeyPressed $arrow
        $state  = $RepeatState[$arrow]
        if ($isDown) {
            if (-not $state.Active) {
                if ($arrow -eq 'Up') { Selector-Prev } else { Selector-Next }
                $state.Active = $true
                $state.Last   = [DateTime]::UtcNow.AddMilliseconds($state.InitialMs)
            } else {
                if ([DateTime]::UtcNow -ge $state.Last) {
                    if ($arrow -eq 'Up') { Selector-Prev } else { Selector-Next }
                    $state.Last = [DateTime]::UtcNow.AddMilliseconds($state.RepeatMs)
                }
            }
        } else {
            $state.Active = $false
            $state.Last   = [DateTime]::MinValue
        }
    }
}

function Selector-Next {
    $global:SelectorIndex = [int]$global:SelectorIndex
    if     ($global:SelectorIndex -eq 1) { $global:SelectorIndex = 2 }
    elseif ($global:SelectorIndex -eq 2) { $global:SelectorIndex = 3 }
    elseif ($global:SelectorIndex -eq 3) { $global:SelectorIndex = 9 }
    elseif ($global:SelectorIndex -eq 9) { $global:SelectorIndex = 1 }
    Display-Overlay
}

function Selector-Prev {
    $global:SelectorIndex = [int]$global:SelectorIndex
    if     ($global:SelectorIndex -eq 1) { $global:SelectorIndex = 9 }
    elseif ($global:SelectorIndex -eq 2) { $global:SelectorIndex = 1 }
    elseif ($global:SelectorIndex -eq 3) { $global:SelectorIndex = 2 }
    elseif ($global:SelectorIndex -eq 9) { $global:SelectorIndex = 3 }
    Display-Overlay
}

function Save-ToSelectedSlotIfManual {
    if ($global:SelectorIndex -in 1,2,3) {
        Backup-Manual
        $OverlayState.Manual[$global:SelectorIndex-1] = ToDisplayTs
        Display-Overlay
    }
}

function Load-SelectedSlot {
    if ($global:SelectorIndex -in 1,2,3) {
        Restore-ManualSlot $global:SelectorIndex
        Show-ReloadConfirmation "[$global:SelectorIndex]"
    }
    elseif ($global:SelectorIndex -eq 9) {
        Restore-AutoLatest
        Show-ReloadConfirmation "[Auto]"
    }
}

# Keypad: direct actions + selected actions
function Handle-NumKeys {
    foreach ($name in @('Num0','Num1','Num2','Num3','Num9','NumAdd')) {
        if (KeyPressed $name) {
            if (-not $KeyDown[$name]) {
                $KeyDown[$name] = $true
                switch ($name) {
                    'Num0'   { Save-ToSelectedSlotIfManual }
                    'Num1'   { Restore-ManualSlot 1 }
                    'Num2'   { Restore-ManualSlot 2 }
                    'Num3'   { Restore-ManualSlot 3 }
                    'Num9'   { Restore-AutoLatest }
                    'NumAdd' { Load-SelectedSlot }
                }
            }
        } else {
            $KeyDown[$name] = $false
        }
    }
}

# Optional: Enter behaves like Num0 (quick save)
function Handle-Enter {
    if (KeyPressed 'Enter') {
        if (-not $KeyDown['Enter']) {
            $KeyDown['Enter'] = $true
            Save-ToSelectedSlotIfManual
        }
    } else {
        $KeyDown['Enter'] = $false
    }
}
