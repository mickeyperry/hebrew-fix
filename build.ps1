# Builds dist\HebrewFix.exe (portable) and dist\HebrewFix-Setup.exe (installer)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force build, dist | Out-Null

$ahk = 'C:\Program Files\AutoHotkey'
# Ahk2Exe needs a base path without spaces, with the .exe extension kept
Copy-Item "$ahk\AutoHotkeyU64.exe" build\AutoHotkeyU64.exe -Force
& "$ahk\Compiler\Ahk2Exe.exe" /in HebrewFix.ahk /out build\HebrewFix.exe /base build\AutoHotkeyU64.exe /silent | Out-Null
while (!(Test-Path build\HebrewFix.exe)) { Start-Sleep -Milliseconds 200 }

$iscc = @("$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe", "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (!(Test-Path build\wizsmall.bmp)) {
    Add-Type -AssemblyName System.Drawing
    $b = New-Object Drawing.Bitmap 110, 106; $g = [Drawing.Graphics]::FromImage($b); $g.Clear([Drawing.Color]::White)
    $g.DrawImage([Drawing.Image]::FromFile("$PSScriptRoot\icon.png"), 7, 5, 96, 96); $g.Dispose()
    $b.Save("$PSScriptRoot\build\wizsmall.bmp", [Drawing.Imaging.ImageFormat]::Bmp)
}
& $iscc /Q installer.iss
Copy-Item build\HebrewFix.exe dist\HebrewFix.exe -Force
Get-ChildItem dist
