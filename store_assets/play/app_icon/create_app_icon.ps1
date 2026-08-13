$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$size = 512
$outputPath = Join-Path $PSScriptRoot "play_icon_512.png"
$sourcePath = Join-Path $PSScriptRoot "launcher_icon_source_1024.png"

function Color-Hex([string]$hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Solid-Brush([System.Drawing.Color]$color) {
    return New-Object System.Drawing.SolidBrush $color
}

function Pen-Color([System.Drawing.Color]$color, [float]$width = 1) {
    $pen = New-Object System.Drawing.Pen $color, $width
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    return $pen
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

function Draw-Icon([int]$canvasSize, [string]$path) {
    $bitmap = New-Object System.Drawing.Bitmap $canvasSize, $canvasSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $scale = $canvasSize / 512.0
    $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
    $clip.AddEllipse(24 * $scale, 24 * $scale, 464 * $scale, 464 * $scale)
    $graphics.SetClip($clip)

    $bgRect = [System.Drawing.RectangleF]::new(0, 0, $canvasSize, $canvasSize)
    $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $bgRect,
        (Color-Hex "#9BD7D5"),
        (Color-Hex "#1D6F78"),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $graphics.FillRectangle($gradient, $bgRect)

    for ($i = 0; $i -lt 5; $i++) {
        $y = (78 + $i * 82) * $scale
        $x = (54 + (($i * 59) % 210)) * $scale
        $graphics.DrawLine((Pen-Color ([System.Drawing.Color]::FromArgb(72, 255, 248, 223)) (4 * $scale)), $x, $y, $x + 78 * $scale, $y - 10 * $scale)
    }

    Fill-RoundRect $graphics (110 * $scale) (344 * $scale) (292 * $scale) (42 * $scale) (14 * $scale) (Solid-Brush ([System.Drawing.Color]::FromArgb(100, 6, 45, 51)))
    Fill-RoundRect $graphics (96 * $scale) (320 * $scale) (320 * $scale) (42 * $scale) (16 * $scale) (Solid-Brush (Color-Hex "#274C48"))
    Fill-RoundRect $graphics (86 * $scale) (296 * $scale) (340 * $scale) (48 * $scale) (18 * $scale) (Solid-Brush (Color-Hex "#FFCB5B"))
    $graphics.DrawLine((Pen-Color ([System.Drawing.Color]::FromArgb(190, 255, 248, 223)) (5 * $scale)), 206 * $scale, 296 * $scale, 318 * $scale, 296 * $scale)

    $cx = 256 * $scale
    $cy = 236 * $scale
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(54, 255, 248, 223))), $cx - 150 * $scale, $cy - 150 * $scale, 300 * $scale, 300 * $scale)
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(218, 255, 203, 91))), $cx - 110 * $scale, $cy - 110 * $scale, 220 * $scale, 220 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#FFF8DF")), $cx - 78 * $scale, $cy - 78 * $scale, 156 * $scale, 156 * $scale)
    $graphics.FillEllipse((Solid-Brush ([System.Drawing.Color]::FromArgb(210, 29, 111, 120))), $cx - 48 * $scale, $cy - 48 * $scale, 96 * $scale, 96 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#062D33")), $cx - 18 * $scale, $cy - 18 * $scale, 36 * $scale, 36 * $scale)
    $graphics.DrawLine((Pen-Color (Color-Hex "#FFF8DF") (10 * $scale)), $cx - 106 * $scale, $cy, $cx + 106 * $scale, $cy)

    $graphics.TranslateTransform($cx, $cy)
    $graphics.RotateTransform(-10)
    Fill-RoundRect $graphics (-68 * $scale) (-92 * $scale) (136 * $scale) (184 * $scale) (26 * $scale) (Solid-Brush (Color-Hex "#F6FBF4"))
    Fill-RoundRect $graphics (-46 * $scale) (-62 * $scale) (92 * $scale) (42 * $scale) (18 * $scale) (Solid-Brush (Color-Hex "#F06B50"))
    $graphics.FillRectangle((Solid-Brush (Color-Hex "#1D6F78")), -42 * $scale, 38 * $scale, 84 * $scale, 28 * $scale)
    $graphics.FillEllipse((Solid-Brush (Color-Hex "#062D33")), 32 * $scale, -42 * $scale, 14 * $scale, 14 * $scale)
    $graphics.ResetTransform()

    $graphics.ResetClip()
    $graphics.DrawEllipse((Pen-Color (Color-Hex "#FFCB5B") (10 * $scale)), 24 * $scale, 24 * $scale, 464 * $scale, 464 * $scale)

    $gradient.Dispose()
    $clip.Dispose()
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

Draw-Icon 512 $outputPath
Draw-Icon 1024 $sourcePath
