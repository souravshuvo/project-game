Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$OutputPath = Join-Path $Root "store_assets/feature_graphic/feature-graphic.png"

function New-Brush($hex) {
    return New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-Pen($hex, $width) {
    $pen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($hex)), $width
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    return $pen
}

function New-RoundedRectanglePath($x, $y, $width, $height, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
    $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Add-RoundedRectangle($graphics, $brush, $x, $y, $width, $height, $radius) {
    $path = New-RoundedRectanglePath $x $y $width $height $radius
    $graphics.FillPath($brush, $path)
    $path.Dispose()
}

function Add-Text($graphics, $text, $fontName, $size, $style, $hex, $x, $y) {
    $font = New-Object System.Drawing.Font($fontName, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $hex
    $graphics.DrawString($text, $font, $brush, $x, $y)
    $brush.Dispose()
    $font.Dispose()
}

function Add-X($graphics, $x, $y, $size, $hex) {
    $pen = New-Pen $hex ([Math]::Max(8, $size * 0.12))
    $inset = $size * 0.28
    $graphics.DrawLine($pen, $x + $inset, $y + $inset, $x + $size - $inset, $y + $size - $inset)
    $graphics.DrawLine($pen, $x + $size - $inset, $y + $inset, $x + $inset, $y + $size - $inset)
    $pen.Dispose()
}

function Add-O($graphics, $x, $y, $size, $hex) {
    $pen = New-Pen $hex ([Math]::Max(8, $size * 0.11))
    $inset = $size * 0.25
    $graphics.DrawEllipse($pen, $x + $inset, $y + $inset, $size - ($inset * 2), $size - ($inset * 2))
    $graphics.DrawArc($pen, $x + ($size * 0.17), $y + ($size * 0.33), $size * 0.66, $size * 0.34, 190, 160)
    $pen.Dispose()
}

function Add-Cell($graphics, $x, $y, $size, $mark) {
    $cellBrush = New-Brush "#F8F2E7"
    Add-RoundedRectangle $graphics $cellBrush $x $y $size $size 8
    if ($mark -eq "x") {
        Add-X $graphics $x $y $size "#7465B8"
    }
    if ($mark -eq "o") {
        Add-O $graphics $x $y $size "#4DB7A8"
    }
    $cellBrush.Dispose()
}

$outputDirectory = Split-Path -Parent $OutputPath
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Force $outputDirectory | Out-Null
}

$bitmap = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#17151F"))

$panel = New-Brush "#24202E"
$gold = New-Brush "#E9B64E"
$cream = New-Brush "#F8F2E7"

Add-RoundedRectangle $graphics $panel 568 42 330 330 18
Add-RoundedRectangle $graphics $cream 592 66 282 282 12

$tileSize = 82
$gap = 9
$startX = 612
$startY = 86
Add-Cell $graphics $startX $startY $tileSize "x"
Add-Cell $graphics ($startX + $tileSize + $gap) $startY $tileSize "o"
Add-Cell $graphics ($startX + (($tileSize + $gap) * 2)) $startY $tileSize "x"
Add-Cell $graphics $startX ($startY + $tileSize + $gap) $tileSize "o"
Add-Cell $graphics ($startX + $tileSize + $gap) ($startY + $tileSize + $gap) $tileSize "x"
Add-Cell $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + $tileSize + $gap) $tileSize ""
Add-Cell $graphics $startX ($startY + (($tileSize + $gap) * 2)) $tileSize ""
Add-Cell $graphics ($startX + $tileSize + $gap) ($startY + (($tileSize + $gap) * 2)) $tileSize "o"
Add-Cell $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + (($tileSize + $gap) * 2)) $tileSize "x"

$winPen = New-Pen "#E9B64E" 12
$graphics.DrawLine($winPen, 646, 120, 828, 302)
$winPen.Dispose()

Add-RoundedRectangle $graphics $gold 76 94 96 96 18
Add-X $graphics 76 94 96 "#17151F"
Add-Text $graphics "Tik Tak Toe" "Segoe UI" 60 ([System.Drawing.FontStyle]::Bold) "#F8F2E7" 76 222
Add-Text $graphics "A calm star-map tic tac toe duel." "Segoe UI" 32 ([System.Drawing.FontStyle]::Regular) "#C9C0B5" 80 304

$sparkPen = New-Pen "#E9B64E" 6
$graphics.DrawLine($sparkPen, 464, 116, 506, 116)
$graphics.DrawLine($sparkPen, 485, 95, 485, 137)
$sparkPen.Dispose()

$bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$panel.Dispose()
$gold.Dispose()
$cream.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Generated Play feature graphic at $OutputPath"
