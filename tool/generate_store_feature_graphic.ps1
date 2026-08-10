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

function Add-LabelTile($graphics, $x, $y, $size, $fillHex, $borderHex, $text, $textHex) {
    $fillBrush = New-Brush $fillHex
    $borderPen = New-Pen $borderHex 5
    $textBrush = New-Brush $textHex
    $font = New-Object System.Drawing.Font("Segoe UI", [Math]::Max(14, $size * 0.22), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $smallPen = New-Pen $textHex ([Math]::Max(2, $size * 0.035))

    $path = New-RoundedRectanglePath $x $y $size $size ([Math]::Max(8, $size * 0.12))
    $graphics.FillPath($fillBrush, $path)
    $graphics.DrawPath($borderPen, $path)
    $path.Dispose()

    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = [System.Drawing.RectangleF]::new($x, $y - ($size * 0.07), $size, $size)
    $graphics.DrawString($text, $font, $textBrush, $rect, $format)
    $graphics.DrawLine($smallPen, $x + ($size * 0.22), $y + ($size * 0.70), $x + ($size * 0.78), $y + ($size * 0.70))
    $graphics.DrawLine($smallPen, $x + ($size * 0.32), $y + ($size * 0.80), $x + ($size * 0.68), $y + ($size * 0.80))

    $format.Dispose()
    $font.Dispose()
    $smallPen.Dispose()
    $textBrush.Dispose()
    $borderPen.Dispose()
    $fillBrush.Dispose()
}

$outputDirectory = Split-Path -Parent $OutputPath
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Force $outputDirectory | Out-Null
}

$bitmap = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#276B63"))

$panel = New-Brush "#F1F7F4"
$deep = New-Brush "#16443F"
$amber = New-Brush "#F0B429"

Add-RoundedRectangle $graphics $deep 604 58 332 332 34
Add-RoundedRectangle $graphics $panel 584 38 332 332 34

$tileSize = 86
$gap = 18
$startX = 622
$startY = 72
Add-LabelTile $graphics $startX $startY $tileSize "#E9F6EE" "#8ACAA4" "JAR" "#276B43"
Add-LabelTile $graphics ($startX + $tileSize + $gap) $startY $tileSize "#EAF1FF" "#9BB8F1" "NOTE" "#345AA6"
Add-LabelTile $graphics ($startX + (($tileSize + $gap) * 2)) $startY $tileSize "#FFE9E5" "#FFA59B" "TIN" "#B54138"
Add-LabelTile $graphics $startX ($startY + $tileSize + $gap) $tileSize "#FFF5D8" "#F0C24D" "FLR" "#926C00"
Add-LabelTile $graphics ($startX + $tileSize + $gap) ($startY + $tileSize + $gap) $tileSize "#E2F7F2" "#77CDBE" "TEA" "#176B62"
Add-LabelTile $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + $tileSize + $gap) $tileSize "#F2EEFF" "#C0AFE8" "SEED" "#6848A8"
Add-LabelTile $graphics $startX ($startY + (($tileSize + $gap) * 2)) $tileSize "#FFEFD6" "#FFB55D" "HNY" "#B15E00"
Add-LabelTile $graphics ($startX + $tileSize + $gap) ($startY + (($tileSize + $gap) * 2)) $tileSize "#E9F3F7" "#93C9DD" "RIB" "#2B6D88"
Add-LabelTile $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + (($tileSize + $gap) * 2)) $tileSize "#F3F1E6" "#D4C981" "OAT" "#6C6642"

Add-LabelTile $graphics 84 88 126 "#FFF5D8" "#F0C24D" "3x" "#16443F"
Add-Text $graphics "Larder Labels" "Segoe UI" 74 ([System.Drawing.FontStyle]::Bold) "#FFFFFF" 76 226
Add-Text $graphics "Match three. Clear the shelf." "Segoe UI" 34 ([System.Drawing.FontStyle]::Regular) "#E3F2EA" 80 320

$sparkPen = New-Pen "#F0B429" 8
$graphics.DrawLine($sparkPen, 456, 112, 500, 112)
$graphics.DrawLine($sparkPen, 478, 90, 478, 134)
$sparkPen.Dispose()

$bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$panel.Dispose()
$deep.Dispose()
$amber.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Generated Larder Labels Play feature graphic at $OutputPath"
