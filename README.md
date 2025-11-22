# 🚀 FTL Backup Overlay

## 🎯 Purpose
This project provides an **interactive PowerShell overlay** for the game *Faster Than Light (FTL)*.  
It enables quick save and restore of game progress with a compact, transparent interface displayed above the game window.

---

## ⚙️ Features
- Transparent overlay positioned at the top‑right of the screen  
- Keyboard controls:  
  - `↑ / ↓` → navigate between slots  
  - `Num0` → save to the selected slot  
  - `Num+` → restore the selected slot  
- Manual saves (slots 1–3) and auto‑save  
- Automatic backup every 10 minutes  
- Game window maximization at launch  
- Instant visual feedback in the overlay after each action  

---

## 📂 Project structure
- `OverlayUI.ps1` → Defines the overlay interface (size, opacity, labels)  
- `OverlayHelpers.ps1` → Utility functions (placement, display, confirmation)  
- `OverlayKeys.ps1` → Keyboard input handling and navigation  
- `OverlayBackup.ps1` → Save/restore logic for FTL profile files  
- `OverlayGame.ps1` → Launches FTL via Steam and maximizes the window  
- `FTLBackup.ps1` → Main script, WinForms loop, autosave, and overlay lifecycle  

---

## ✅ Highlights
- Compact, readable interface  
- Fast manual and automatic saves  
- Intuitive keyboard navigation  
- Stable **V1 release** with consistent modules and documentation  
