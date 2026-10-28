# Gera assets/avatar.png (20px, redondo) a partir da foto da conta do Windows.
# So regenera quando a foto da conta muda; depois recarrega o YASB.
param([int]$Size = 20, [switch]$Force)

Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$dest = Join-Path $root "assets\avatar.png"
$stamp = Join-Path $root "assets\avatar.source"

$sid = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
$reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\$sid" -ErrorAction SilentlyContinue
$src = if ($reg) { $reg.Image192 }
if (-not $src -or -not [IO.File]::Exists($src)) { exit 0 }

# Identifica a foto atual pelo caminho + data de modificacao
$id = "$src|$([IO.File]::GetLastWriteTimeUtc($src).Ticks)|$Size"
if (-not $Force -and (Test-Path $dest) -and (Test-Path $stamp) -and ((Get-Content $stamp -Raw).Trim() -eq $id)) { exit 0 }

New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
$img = [System.Drawing.Image]::FromFile($src)
try {
    # Desenha em 4x e reduz, para bordas suaves e foto nitida
    $ss = 4
    $big = New-Object System.Drawing.Bitmap ($Size * $ss), ($Size * $ss)
    $g = [System.Drawing.Graphics]::FromImage($big)
    $g.SmoothingMode = "AntiAlias"; $g.InterpolationMode = "HighQualityBicubic"; $g.PixelOffsetMode = "HighQuality"
    $g.Clear([System.Drawing.Color]::Transparent)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, $Size * $ss, $Size * $ss)
    $g.SetClip($path); $g.DrawImage($img, 0, 0, $Size * $ss, $Size * $ss); $g.Dispose()

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = "HighQualityBicubic"; $g.PixelOffsetMode = "HighQuality"
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($big, 0, 0, $Size, $Size); $g.Dispose()
    $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose(); $big.Dispose()
} finally { $img.Dispose() }

Set-Content -Path $stamp -Value $id -Encoding UTF8

if (Get-Process yasb -ErrorAction SilentlyContinue) { & "C:\Program Files\YASB\yasbc.exe" reload | Out-Null }
