$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 500
$outputPath = Join-Path $PSScriptRoot "feature_graphic.png"

$bitmap = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

function Color-Hex([string]$hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Solid-Brush([System.Drawing.Color]$color) {
    return New-Object System.Drawing.SolidBrush $color
}

function Pen-Color([System.Drawing.Color]$color, [float]$width = 1) {
    return New-Object System.Drawing.Pen $color, $width
}

function Fill-RoundRect(
    [System.Drawing.Graphics]$g,
    [float]$x,
    [float]$y,
    [float]$w,
    [float]$h,
    [float]$r,
    [System.Drawing.Brush]$brush
) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $g.FillPath($brush, $path)
    $path.Dispose()
}

function Draw-Platform([float]$x, [float]$y, [float]$w) {
    Fill-RoundRect $graphics $x ($y + 12) $w 30 8 (Solid-Brush ([System.Drawing.Color]::FromArgb(120, 6, 45, 51)))
    Fill-RoundRect $graphics $x ($y + 4) $w 28 8 (Solid-Brush (Color-Hex "#274C48"))
    Fill-RoundRect $graphics $x ($y - 4) $w 18 8 (Solid-Brush (Color-Hex "#FFCB5B"))
    $graphics.DrawLine(
        (Pen-Color ([System.Drawing.Color]::FromArgb(180, 255, 248, 223)) 4),
        $x + $w * 0.43,
        $y - 4,
        $x + $w * 0.65,
        $y - 4
    )
}

function Draw-Signal([float]$cx, [float]$cy, [float]$scale = 1) {
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(54, 255, 248, 223))), $cx - 26 * $scale, $cy - 26 * $scale, 52 * $scale, 52 * $scale)
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(220, 255, 203, 91))), $cx - 15 * $scale, $cy - 15 * $scale, 30 * $scale, 30 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#1D6F78")), $cx - 7 * $scale, $cy - 7 * $scale, 14 * $scale, 14 * $scale)
    $graphics.DrawLine((Pen-Color ([System.Drawing.Color]::FromArgb(210, 255, 248, 223)) (3 * $scale)), $cx - 22 * $scale, $cy, $cx + 22 * $scale, $cy)
}

function Draw-Spark([float]$cx, [float]$baseY, [float]$scale = 1) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon(@(
        [System.Drawing.PointF]::new($cx - 28 * $scale, $baseY),
        [System.Drawing.PointF]::new($cx, $baseY - 70 * $scale),
        [System.Drawing.PointF]::new($cx + 28 * $scale, $baseY)
    ))
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(42, 255, 241, 166))), $cx - 50 * $scale, $baseY - 82 * $scale, 100 * $scale, 100 * $scale)
    $graphics.FillPath((Solid-Brush (Color-Hex "#FF5B46")), $path)
    $graphics.DrawLine((Pen-Color (Color-Hex "#FFF1A6") (4 * $scale)), $cx - 12 * $scale, $baseY - 30 * $scale, $cx - 2 * $scale, $baseY - 48 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#FFF1A6")), $cx - 36 * $scale, $baseY - 58 * $scale, 8 * $scale, 8 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#FFF1A6")), $cx + 30 * $scale, $baseY - 62 * $scale, 8 * $scale, 8 * $scale)
    $path.Dispose()
}

function Draw-Courier([float]$cx, [float]$cy, [float]$scale = 1, [float]$angle = -12) {
    $graphics.TranslateTransform($cx, $cy)
    $graphics.RotateTransform($angle)
    $graphics.ScaleTransform($scale, $scale)
    Fill-RoundRect $graphics -36 -48 72 96 14 (Solid-Brush (Color-Hex "#F6FBF4"))
    Fill-RoundRect $graphics -24 -32 48 22 9 (Solid-Brush (Color-Hex "#F06B50"))
    $graphics.FillRectangle((Solid-Brush (Color-Hex "#1D6F78")), -22, 22, 44, 14)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#062D33")), 14, -22, 8, 8)
    $graphics.ResetTransform()

    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(70, 6, 45, 51))), $cx - 45 * $scale, $cy + 55 * $scale, 90 * $scale, 14 * $scale)
    for ($i = 0; $i -lt 4; $i++) {
        Fill-RoundRect $graphics ($cx - 20 + $i * 6) ($cy + 70 + $i * 18) (44 - $i * 7) 9 6 (Solid-Brush ([System.Drawing.Color]::FromArgb((80 - $i * 14), 255, 248, 223)))
    }
}

$backgroundRect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
$gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $backgroundRect,
    (Color-Hex "#FFF2C6"),
    (Color-Hex "#1D6F78"),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($gradient, $backgroundRect)

for ($i = 0; $i -lt 7; $i++) {
    $x = 40 + $i * 150
    $y = 55 + (($i * 73) % 330)
    $graphics.DrawLine((Pen-Color ([System.Drawing.Color]::FromArgb(78, 255, 248, 223)) 3), $x, $y, $x + 62, $y - 8)
}

Fill-RoundRect $graphics 682 40 235 24 10 (Solid-Brush ([System.Drawing.Color]::FromArgb(70, 31, 91, 97)))
Fill-RoundRect $graphics 120 370 230 24 10 (Solid-Brush ([System.Drawing.Color]::FromArgb(62, 31, 91, 97)))

Draw-Platform 586 116 306
Draw-Platform 685 262 238
Draw-Platform 510 398 328
Draw-Platform 792 38 150

Draw-Spark 742 116 0.72
Draw-Signal 585 88 0.85
Draw-Signal 906 218 0.7
Draw-Signal 626 340 0.62
Draw-Courier 700 220 1.25 -13

$titleFont = New-Object System.Drawing.Font "Arial Black", 48, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$titleFont2 = New-Object System.Drawing.Font "Arial Black", 66, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$subFont = New-Object System.Drawing.Font "Arial", 24, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)

$shadowBrush = Solid-Brush ([System.Drawing.Color]::FromArgb(80, 6, 45, 51))
$titleBrush = Solid-Brush (Color-Hex "#062D33")
$accentBrush = Solid-Brush (Color-Hex "#D64C35")

$graphics.DrawString("Cloud Courier", $titleFont, $shadowBrush, 64, 123)
$graphics.DrawString("Cloud Courier", $titleFont, $titleBrush, 60, 118)
$graphics.DrawString("Climb", $titleFont2, $shadowBrush, 64, 180)
$graphics.DrawString("Climb", $titleFont2, $titleBrush, 60, 174)

Fill-RoundRect $graphics 62 265 294 11 5 $accentBrush
$graphics.DrawString("Jump. Steer. Deliver.", $subFont, $titleBrush, 62, 292)

$titleFont.Dispose()
$titleFont2.Dispose()
$subFont.Dispose()
$shadowBrush.Dispose()
$titleBrush.Dispose()
$accentBrush.Dispose()
$gradient.Dispose()

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()
