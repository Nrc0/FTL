# === Overlay UI ===
# Defines the overlay form and labels.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.BackColor = [Drawing.Color]::Black
$form.Opacity = 0.65
$form.Width  = 450   # plus large
$form.Height = 140   # plus haut

function New-Label($text, $color = "LightSkyBlue") {
    $lbl = New-Object Windows.Forms.Label
    $lbl.ForeColor = [Drawing.Color]::$color
    $lbl.Font = New-Object Drawing.Font("Consolas", 10, [Drawing.FontStyle]::Regular)
    $lbl.AutoSize = $true
    $lbl.Text = $text
    return $lbl
}

$lblLine0 = New-Label "[↑/↓] Select | [0]: Save | [+]: Load"
$lblLine1 = New-Label "" "White"
$lblLine2 = New-Label "" "White"
$lblLine3 = New-Label "" "White"
$lblAuto  = New-Label "" "Green"

$paddingX = 15
$paddingY = 10       # plus de marge en haut
$lineStep = 25       # plus d’espace entre les lignes

$lblLine0.Location = [System.Drawing.Point]::new($paddingX, $paddingY + 0*$lineStep)
$lblLine1.Location = [System.Drawing.Point]::new($paddingX, $paddingY + 1*$lineStep)
$lblLine2.Location = [System.Drawing.Point]::new($paddingX, $paddingY + 2*$lineStep)
$lblLine3.Location = [System.Drawing.Point]::new($paddingX, $paddingY + 3*$lineStep)
$lblAuto.Location  = [System.Drawing.Point]::new($paddingX, $paddingY + 4*$lineStep)

$form.Controls.AddRange(@($lblLine0,$lblLine1,$lblLine2,$lblLine3,$lblAuto))


# Expose labels
Set-Variable -Name form      -Value $form      -Scope Script
Set-Variable -Name lblLine0  -Value $lblLine0  -Scope Script
Set-Variable -Name lblLine1  -Value $lblLine1  -Scope Script
Set-Variable -Name lblLine2  -Value $lblLine2  -Scope Script
Set-Variable -Name lblLine3  -Value $lblLine3  -Scope Script
Set-Variable -Name lblAuto   -Value $lblAuto   -Scope Script
