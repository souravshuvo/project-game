Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$width = 1024
$height = 500
$outputPath = Join-Path $PSScriptRoot 'feature-graphic-dew-bubble-garden.png'

function New-Color([string]$hex, [int]$alpha = 255) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
}

function Fill-RoundedRectangle(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Brush]$brush,
    [float]$x,
    [float]$y,
    [float]$w,
    [float]$h,
    [float]$radius
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $graphics.FillPath($brush, $path)
    $path.Dispose()
}

function Draw-Leaf(
    [System.Drawing.Graphics]$graphics,
    [float]$cx,
    [float]$cy,
    [float]$scale,
    [float]$angle,
    [System.Drawing.Color]$color
) {
    $state = $graphics.Save()
    $graphics.TranslateTransform($cx, $cy)
    $graphics.RotateTransform($angle)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddBezier(
        [System.Drawing.PointF]::new(-44 * $scale, 0),
        [System.Drawing.PointF]::new(-12 * $scale, -42 * $scale),
        [System.Drawing.PointF]::new(42 * $scale, -35 * $scale),
        [System.Drawing.PointF]::new(58 * $scale, 0)
    )
    $path.AddBezier(
        [System.Drawing.PointF]::new(58 * $scale, 0),
        [System.Drawing.PointF]::new(34 * $scale, 34 * $scale),
        [System.Drawing.PointF]::new(-20 * $scale, 38 * $scale),
        [System.Drawing.PointF]::new(-44 * $scale, 0)
    )
    $path.CloseFigure()
    $brush = [System.Drawing.SolidBrush]::new($color)
    $graphics.FillPath($brush, $path)
    $veinPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(58, 49, 66, 94), [Math]::Max(1.0, 2.0 * $scale))
    $graphics.DrawBezier(
        $veinPen,
        [System.Drawing.PointF]::new(-32 * $scale, 1 * $scale),
        [System.Drawing.PointF]::new(-4 * $scale, -8 * $scale),
        [System.Drawing.PointF]::new(28 * $scale, -6 * $scale),
        [System.Drawing.PointF]::new(48 * $scale, 0)
    )
    $veinPen.Dispose()
    $brush.Dispose()
    $path.Dispose()
    $graphics.Restore($state)
}

function Draw-Bubble(
    [System.Drawing.Graphics]$graphics,
    [float]$cx,
    [float]$cy,
    [float]$radius,
    [string]$baseHex
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddEllipse($cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

    $base = New-Color $baseHex
    $glow = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
    $brush = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
    $brush.CenterPoint = [System.Drawing.PointF]::new($cx - ($radius * 0.32), $cy - ($radius * 0.40))
    $brush.CenterColor = [System.Drawing.Color]::FromArgb(245, 255, 255, 255)
    $brush.SurroundColors = [System.Drawing.Color[]]@($base)
    $graphics.FillPath($brush, $path)

    $rimPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(85, 49, 66, 94), [Math]::Max(2.0, $radius * 0.045))
    $graphics.DrawEllipse($rimPen, $cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

    $highlight = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(145, $glow))
    $graphics.FillEllipse($highlight, $cx - ($radius * 0.45), $cy - ($radius * 0.52), $radius * 0.56, $radius * 0.34)

    $shine = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 255, 255, 255))
    $graphics.FillEllipse($shine, $cx + ($radius * 0.22), $cy + ($radius * 0.18), $radius * 0.42, $radius * 0.28)

    $shine.Dispose()
    $highlight.Dispose()
    $rimPen.Dispose()
    $brush.Dispose()
    $path.Dispose()
}

$bitmap = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$backgroundRect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
$background = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $backgroundRect,
    (New-Color '#E7FAFF'),
    (New-Color '#FFF8E6'),
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
)
$graphics.FillRectangle($background, $backgroundRect)

$wash = [System.Drawing.SolidBrush]::new((New-Color '#F7F0FF' 160))
$graphics.FillEllipse($wash, 582, -150, 540, 330)
$graphics.FillEllipse($wash, -190, 290, 470, 310)
$wash.Dispose()

Draw-Leaf $graphics 885 70 1.0 -24 (New-Color '#BCECC5' 112)
Draw-Leaf $graphics 940 398 1.45 20 (New-Color '#BCECC5' 126)
Draw-Leaf $graphics 93 380 1.25 -16 (New-Color '#BCECC5' 112)
Draw-Leaf $graphics 762 442 1.0 -12 (New-Color '#93DEB4' 135)

$titleColor = New-Color '#243C4A'
$titleBrush = [System.Drawing.SolidBrush]::new($titleColor)
$accentBrush = [System.Drawing.SolidBrush]::new((New-Color '#2CB9A0'))
$shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(55, 49, 66, 94))
$titleFont = [System.Drawing.Font]::new('Segoe UI Black', 64, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$gardenFont = [System.Drawing.Font]::new('Segoe UI Black', 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

$graphics.DrawString('Dew Bubble', $titleFont, $shadowBrush, 61, 127)
$graphics.DrawString('Dew Bubble', $titleFont, $titleBrush, 58, 122)
$graphics.DrawString('Garden', $gardenFont, $shadowBrush, 61, 199)
$graphics.DrawString('Garden', $gardenFont, $accentBrush, 58, 194)

$smallDewBrush = [System.Drawing.SolidBrush]::new((New-Color '#67B8F7' 185))
$graphics.FillEllipse($smallDewBrush, 392, 103, 38, 38)
$smallDewBrush.Dispose()

$groundBrush = [System.Drawing.SolidBrush]::new((New-Color '#DDF5D5'))
$graphics.FillEllipse($groundBrush, 420, 368, 535, 165)
$groundBrush.Dispose()

$panelBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(102, 255, 255, 255))
Fill-RoundedRectangle $graphics $panelBrush 494 58 424 324 42
$panelBrush.Dispose()

$linePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(205, 49, 66, 94), 6)
$linePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$linePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$linePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$linePen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Solid
$graphics.DrawLine($linePen, 660, 415, 906, 230)
$graphics.DrawLine($linePen, 906, 230, 778, 126)
$bounceBrush = [System.Drawing.SolidBrush]::new((New-Color '#31425E' 190))
$graphics.FillEllipse($bounceBrush, 894, 218, 24, 24)
$bounceBrush.Dispose()
$linePen.Dispose()

$lineGlow = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 255, 255, 255), 2)
$lineGlow.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$lineGlow.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($lineGlow, 660, 415, 906, 230)
$graphics.DrawLine($lineGlow, 906, 230, 778, 126)
$lineGlow.Dispose()

$bubbles = @(
    @(656, 126, 43, '#35A7FF'),
    @(739, 126, 43, '#EF5DA8'),
    @(822, 126, 43, '#FFB72B'),
    @(697, 202, 43, '#2DBE88'),
    @(780, 202, 43, '#35A7FF'),
    @(863, 202, 43, '#EF5DA8'),
    @(656, 278, 43, '#FFB72B'),
    @(739, 278, 43, '#2DBE88'),
    @(822, 278, 43, '#35A7FF')
)

foreach ($bubble in $bubbles) {
    Draw-Bubble $graphics ([float]$bubble[0]) ([float]$bubble[1]) ([float]$bubble[2]) ([string]$bubble[3])
}

$cupPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$cupPath.AddBezier(
    [System.Drawing.PointF]::new(598, 418),
    [System.Drawing.PointF]::new(620, 478),
    [System.Drawing.PointF]::new(705, 478),
    [System.Drawing.PointF]::new(727, 418)
)
$cupPath.AddBezier(
    [System.Drawing.PointF]::new(727, 418),
    [System.Drawing.PointF]::new(700, 438),
    [System.Drawing.PointF]::new(623, 438),
    [System.Drawing.PointF]::new(598, 418)
)
$cupPath.CloseFigure()
$cupBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.RectangleF]::new(592, 398, 144, 88),
    (New-Color '#31425E'),
    (New-Color '#56708D'),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillPath($cupBrush, $cupPath)
$cupBrush.Dispose()

$rimPen = [System.Drawing.Pen]::new((New-Color '#FFFFFF'), 9)
$rimPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$rimPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawBezier($rimPen, 598, 418, 626, 396, 700, 396, 727, 418)
$rimPen.Dispose()
$cupPath.Dispose()

Draw-Bubble $graphics 662 392 38 '#FFB72B'

$graphics.Flush()
$background.Dispose()
$titleBrush.Dispose()
$accentBrush.Dispose()
$shadowBrush.Dispose()
$titleFont.Dispose()
$gardenFont.Dispose()

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Wrote $outputPath"
