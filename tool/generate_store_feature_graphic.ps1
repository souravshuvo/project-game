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

function Add-Text($graphics, $text, $fontName, $size, $style, $hex, $x, $y) {
    $font = New-Object System.Drawing.Font($fontName, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $hex
    $graphics.DrawString($text, $font, $brush, $x, $y)
    $brush.Dispose()
    $font.Dispose()
}

function Add-SignalShip($graphics, $cx, $cy, $scale) {
    $shipBrush = New-Brush "#50D6C7"
    $coreBrush = New-Brush "#FFFFFF"
    $trailPen = New-Pen "#FFC857" (9 * $scale)
    $ship = New-Object System.Drawing.Drawing2D.GraphicsPath
    $ship.AddPolygon(@(
        [System.Drawing.PointF]::new($cx, $cy - (92 * $scale)),
        [System.Drawing.PointF]::new($cx + (54 * $scale), $cy + (60 * $scale)),
        [System.Drawing.PointF]::new($cx, $cy + (96 * $scale)),
        [System.Drawing.PointF]::new($cx - (54 * $scale), $cy + (60 * $scale))
    ))
    $graphics.FillPath($shipBrush, $ship)
    $graphics.FillEllipse($coreBrush, $cx - (15 * $scale), $cy - (24 * $scale), 30 * $scale, 30 * $scale)
    $graphics.DrawLine($trailPen, $cx, $cy + (78 * $scale), $cx, $cy + (128 * $scale))

    $ship.Dispose()
    $shipBrush.Dispose()
    $coreBrush.Dispose()
    $trailPen.Dispose()
}

function Add-DriftNode($graphics, $cx, $cy, $size) {
    $brush = New-Brush "#50D6C7"
    $core = New-Brush "#0C3B46"
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon(@(
        [System.Drawing.PointF]::new($cx, $cy - $size),
        [System.Drawing.PointF]::new($cx + $size, $cy),
        [System.Drawing.PointF]::new($cx, $cy + $size),
        [System.Drawing.PointF]::new($cx - $size, $cy)
    ))
    $graphics.FillPath($brush, $path)
    $graphics.FillEllipse($core, $cx - ($size * 0.28), $cy - ($size * 0.28), $size * 0.56, $size * 0.56)
    $path.Dispose()
    $brush.Dispose()
    $core.Dispose()
}

function Add-PulseSeed($graphics, $cx, $cy, $width, $height) {
    $shell = New-Brush "#FFC857"
    $core = New-Brush "#453212"
    $ring = New-Pen "#FFF3B0" 4
    $graphics.FillEllipse($shell, $cx - ($width / 2), $cy - ($height / 2), $width, $height)
    $graphics.FillEllipse($core, $cx - 16, $cy - 16, 32, 32)
    $graphics.DrawArc($ring, $cx - ($width / 2) + 8, $cy - ($height / 2) + 10, $width - 16, $height - 20, 20, 240)
    $shell.Dispose()
    $core.Dispose()
    $ring.Dispose()
}

$outputDirectory = Split-Path -Parent $OutputPath
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Force $outputDirectory | Out-Null
}

$bitmap = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#07131E"))

$background = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.RectangleF]::new(0, 0, 1024, 500),
    [System.Drawing.ColorTranslator]::FromHtml("#07131E"),
    [System.Drawing.ColorTranslator]::FromHtml("#092621"),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($background, 0, 0, 1024, 500)

$currentPen = New-Pen "#1F6C80" 3
$pulsePen = New-Pen "#B7FFF6" 7
$enemyPulsePen = New-Pen "#FF6B6B" 5

for ($y = -60; $y -lt 560; $y += 96) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddBezier(
        [System.Drawing.PointF]::new(-30, $y),
        [System.Drawing.PointF]::new(260, $y + 82),
        [System.Drawing.PointF]::new(700, $y - 22),
        [System.Drawing.PointF]::new(1054, $y + 36)
    )
    $graphics.DrawPath($currentPen, $path)
    $path.Dispose()
}

Add-SignalShip $graphics 690 306 1.18
Add-DriftNode $graphics 814 132 35
Add-DriftNode $graphics 900 218 28
Add-PulseSeed $graphics 774 222 62 74

$graphics.DrawArc($pulsePen, 610, 118, 292, 230, 205, 118)
$graphics.DrawLine($pulsePen, 604, 374, 942, 174)
$graphics.DrawLine($enemyPulsePen, 774, 262, 774, 332)

Add-Text $graphics "Signal Reef" "Segoe UI" 78 ([System.Drawing.FontStyle]::Bold) "#EAF7F4" 72 142
Add-Text $graphics "Bounce signal shots through short wave runs" "Segoe UI" 32 ([System.Drawing.FontStyle]::Regular) "#B7FFF6" 78 244

$bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$currentPen.Dispose()
$pulsePen.Dispose()
$enemyPulsePen.Dispose()
$background.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Generated Signal Reef Play feature graphic at $OutputPath"
