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

function Add-Arrow($graphics, $x, $y, $size, $direction, $hex) {
    $pen = New-Pen $hex ([Math]::Max(4, $size * 0.11))
    $brush = New-Brush $hex
    $half = $size / 2
    $shaft = $size * 0.22
    $head = $size * 0.24

    switch ($direction) {
        "right" {
            $graphics.DrawLine($pen, $x - $shaft, $y, $x + $shaft, $y)
            $points = @(
                [System.Drawing.PointF]::new($x + $half - $head, $y - $head),
                [System.Drawing.PointF]::new($x + $half, $y),
                [System.Drawing.PointF]::new($x + $half - $head, $y + $head)
            )
        }
        "left" {
            $graphics.DrawLine($pen, $x + $shaft, $y, $x - $shaft, $y)
            $points = @(
                [System.Drawing.PointF]::new($x - $half + $head, $y - $head),
                [System.Drawing.PointF]::new($x - $half, $y),
                [System.Drawing.PointF]::new($x - $half + $head, $y + $head)
            )
        }
        "down" {
            $graphics.DrawLine($pen, $x, $y - $shaft, $x, $y + $shaft)
            $points = @(
                [System.Drawing.PointF]::new($x - $head, $y + $half - $head),
                [System.Drawing.PointF]::new($x, $y + $half),
                [System.Drawing.PointF]::new($x + $head, $y + $half - $head)
            )
        }
        default {
            $graphics.DrawLine($pen, $x, $y + $shaft, $x, $y - $shaft)
            $points = @(
                [System.Drawing.PointF]::new($x - $head, $y - $half + $head),
                [System.Drawing.PointF]::new($x, $y - $half),
                [System.Drawing.PointF]::new($x + $head, $y - $half + $head)
            )
        }
    }

    $graphics.FillPolygon($brush, $points)
    $pen.Dispose()
    $brush.Dispose()
}

function Add-Tile($graphics, $x, $y, $size, $direction, $fillHex, $arrowHex) {
    $brush = New-Brush $fillHex
    Add-RoundedRectangle $graphics $brush $x $y $size $size 18
    Add-Arrow $graphics ($x + ($size / 2)) ($y + ($size / 2)) ($size * 0.5) $direction $arrowHex
    $brush.Dispose()
}

function Add-Text($graphics, $text, $fontName, $size, $style, $hex, $x, $y) {
    $font = New-Object System.Drawing.Font($fontName, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $hex
    $graphics.DrawString($text, $font, $brush, $x, $y)
    $brush.Dispose()
    $font.Dispose()
}

$outputDirectory = Split-Path -Parent $OutputPath
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Force $outputDirectory | Out-Null
}

$bitmap = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#4B68A5"))

$navy = New-Brush "#2E477C"
$white = New-Brush "#FFFFFF"
$gold = New-Brush "#FFC531"

Add-RoundedRectangle $graphics $navy 610 62 314 314 42
Add-RoundedRectangle $graphics $white 590 42 314 314 42

$tileSize = 82
$gap = 20
$startX = 624
$startY = 76
Add-Tile $graphics $startX $startY $tileSize "right" "#FFC531" "#2E477C"
Add-Tile $graphics ($startX + $tileSize + $gap) $startY $tileSize "down" "#F7F2E8" "#2E477C"
Add-Tile $graphics ($startX + (($tileSize + $gap) * 2)) $startY $tileSize "left" "#47C3B8" "#2E477C"
Add-Tile $graphics $startX ($startY + $tileSize + $gap) $tileSize "up" "#F7F2E8" "#2E477C"
Add-Tile $graphics ($startX + $tileSize + $gap) ($startY + $tileSize + $gap) $tileSize "left" "#FFC531" "#2E477C"
Add-Tile $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + $tileSize + $gap) $tileSize "down" "#F7F2E8" "#2E477C"
Add-Tile $graphics $startX ($startY + (($tileSize + $gap) * 2)) $tileSize "right" "#F06C8E" "#2E477C"
Add-Tile $graphics ($startX + $tileSize + $gap) ($startY + (($tileSize + $gap) * 2)) $tileSize "up" "#F7F2E8" "#2E477C"
Add-Tile $graphics ($startX + (($tileSize + $gap) * 2)) ($startY + (($tileSize + $gap) * 2)) $tileSize "left" "#FFC531" "#2E477C"

Add-RoundedRectangle $graphics $gold 78 94 122 122 28
Add-RoundedRectangle $graphics $white 104 120 70 70 16
Add-Arrow $graphics 139 155 44 "right" "#4B68A5"

Add-Text $graphics "Weather Lab Sort" "Segoe UI" 64 ([System.Drawing.FontStyle]::Bold) "#FFFFFF" 76 230
Add-Text $graphics "Tap arrows. Clear the board." "Segoe UI" 34 ([System.Drawing.FontStyle]::Regular) "#F7F2E8" 80 324

$sparkPen = New-Pen "#FFC531" 8
$graphics.DrawLine($sparkPen, 456, 106, 500, 106)
$graphics.DrawLine($sparkPen, 478, 84, 478, 128)
$sparkPen.Dispose()

$bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$navy.Dispose()
$white.Dispose()
$gold.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Generated Play feature graphic at $OutputPath"
