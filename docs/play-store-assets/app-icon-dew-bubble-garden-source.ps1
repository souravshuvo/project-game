Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$sourceSize = 1024
$playSize = 512
$sourcePath = Join-Path $PSScriptRoot 'app-icon-dew-bubble-garden-source-1024.png'
$playPath = Join-Path $PSScriptRoot 'app-icon-dew-bubble-garden-play-512.png'

function New-Color([string]$hex, [int]$alpha = 255) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
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
        [System.Drawing.PointF]::new(-310 * $scale, 0),
        [System.Drawing.PointF]::new(-165 * $scale, -205 * $scale),
        [System.Drawing.PointF]::new(160 * $scale, -210 * $scale),
        [System.Drawing.PointF]::new(330 * $scale, 0)
    )
    $path.AddBezier(
        [System.Drawing.PointF]::new(330 * $scale, 0),
        [System.Drawing.PointF]::new(150 * $scale, 170 * $scale),
        [System.Drawing.PointF]::new(-145 * $scale, 190 * $scale),
        [System.Drawing.PointF]::new(-310 * $scale, 0)
    )
    $path.CloseFigure()

    $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.RectangleF]::new(-330 * $scale, -210 * $scale, 660 * $scale, 400 * $scale),
        $color,
        (New-Color '#93DEB4'),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $graphics.FillPath($brush, $path)

    $veinPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(92, 49, 66, 94), [Math]::Max(5.0, 12.0 * $scale))
    $veinPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $veinPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawBezier(
        $veinPen,
        [System.Drawing.PointF]::new(-250 * $scale, 4 * $scale),
        [System.Drawing.PointF]::new(-80 * $scale, -48 * $scale),
        [System.Drawing.PointF]::new(120 * $scale, -42 * $scale),
        [System.Drawing.PointF]::new(255 * $scale, 2 * $scale)
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
    [float]$radius
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddEllipse($cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

    $brush = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
    $brush.CenterPoint = [System.Drawing.PointF]::new($cx - ($radius * 0.36), $cy - ($radius * 0.44))
    $brush.CenterColor = [System.Drawing.Color]::FromArgb(255, 250, 255, 255)
    $brush.SurroundColors = [System.Drawing.Color[]]@((New-Color '#35A7FF'))
    $graphics.FillPath($brush, $path)

    $rimPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(125, 49, 66, 94), [Math]::Max(8.0, $radius * 0.045))
    $graphics.DrawEllipse($rimPen, $cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

    $innerGlow = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(150, 255, 255, 255), [Math]::Max(5.0, $radius * 0.025))
    $graphics.DrawEllipse($innerGlow, $cx - $radius + 18, $cy - $radius + 18, ($radius * 2) - 36, ($radius * 2) - 36)

    $highlight = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(205, 255, 255, 255))
    $graphics.FillEllipse($highlight, $cx - ($radius * 0.48), $cy - ($radius * 0.55), $radius * 0.58, $radius * 0.34)

    $smallHighlight = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(92, 255, 255, 255))
    $graphics.FillEllipse($smallHighlight, $cx + ($radius * 0.24), $cy + ($radius * 0.10), $radius * 0.42, $radius * 0.25)

    $smallHighlight.Dispose()
    $highlight.Dispose()
    $innerGlow.Dispose()
    $rimPen.Dispose()
    $brush.Dispose()
    $path.Dispose()
}

function Draw-Droplet(
    [System.Drawing.Graphics]$graphics,
    [float]$cx,
    [float]$cy,
    [float]$radius,
    [System.Drawing.Color]$color
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddBezier(
        [System.Drawing.PointF]::new($cx, $cy - ($radius * 1.32)),
        [System.Drawing.PointF]::new($cx - ($radius * 1.05), $cy - ($radius * 0.20)),
        [System.Drawing.PointF]::new($cx - ($radius * 0.72), $cy + ($radius * 0.90)),
        [System.Drawing.PointF]::new($cx, $cy + $radius)
    )
    $path.AddBezier(
        [System.Drawing.PointF]::new($cx, $cy + $radius),
        [System.Drawing.PointF]::new($cx + ($radius * 0.72), $cy + ($radius * 0.90)),
        [System.Drawing.PointF]::new($cx + ($radius * 1.05), $cy - ($radius * 0.20)),
        [System.Drawing.PointF]::new($cx, $cy - ($radius * 1.32))
    )
    $path.CloseFigure()
    $brush = [System.Drawing.SolidBrush]::new($color)
    $graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function New-IconBitmap([int]$size) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $rect = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
    $background = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        (New-Color '#E7FAFF'),
        (New-Color '#FFF8E6'),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $graphics.FillRectangle($background, $rect)

    $washBrush = [System.Drawing.SolidBrush]::new((New-Color '#F7F0FF' 150))
    $graphics.FillEllipse($washBrush, -($size * 0.22), $size * 0.62, $size * 0.72, $size * 0.44)
    $graphics.FillEllipse($washBrush, $size * 0.58, -($size * 0.18), $size * 0.62, $size * 0.42)
    $washBrush.Dispose()

    $s = $size / 1024.0
    Draw-Leaf $graphics (506 * $s) (710 * $s) $s -15 (New-Color '#2DBE88')
    Draw-Leaf $graphics (652 * $s) (768 * $s) ($s * 0.72) 19 (New-Color '#2CB9A0')

    Draw-Droplet $graphics (735 * $s) (240 * $s) (56 * $s) (New-Color '#FFB72B' 225)
    Draw-Droplet $graphics (314 * $s) (228 * $s) (38 * $s) (New-Color '#EF5DA8' 205)

    Draw-Bubble $graphics (512 * $s) (462 * $s) (304 * $s)

    $sparklePen = [System.Drawing.Pen]::new((New-Color '#FFFFFF' 190), [Math]::Max(3.0, 7.0 * $s))
    $sparklePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $sparklePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($sparklePen, 786 * $s, 664 * $s, 846 * $s, 664 * $s)
    $graphics.DrawLine($sparklePen, 816 * $s, 634 * $s, 816 * $s, 694 * $s)
    $sparklePen.Dispose()

    $background.Dispose()
    $graphics.Flush()
    $graphics.Dispose()
    return $bitmap
}

function Resize-Bitmap([System.Drawing.Bitmap]$source, [int]$size) {
    $target = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($target)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($source, 0, 0, $size, $size)
    $graphics.Flush()
    $graphics.Dispose()
    return $target
}

$sourceIcon = New-IconBitmap $sourceSize
$sourceIcon.Save($sourcePath, [System.Drawing.Imaging.ImageFormat]::Png)

$playIcon = Resize-Bitmap $sourceIcon $playSize
$playIcon.Save($playPath, [System.Drawing.Imaging.ImageFormat]::Png)

$playIcon.Dispose()
$sourceIcon.Dispose()

Write-Host "Wrote $playPath"
Write-Host "Wrote $sourcePath"
