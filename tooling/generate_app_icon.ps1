param(
    [string]$OutPath = (Join-Path $PSScriptRoot '..\store_assets\pencil_pitch_app_icon_512.png')
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function Get-Color([string]$Hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function New-Brush([string]$Hex) {
    return [System.Drawing.SolidBrush]::new((Get-Color $Hex))
}

function New-AlphaBrush([int]$Alpha, [string]$Hex) {
    $base = Get-Color $Hex
    return [System.Drawing.SolidBrush]::new(
        [System.Drawing.Color]::FromArgb($Alpha, $base.R, $base.G, $base.B)
    )
}

function New-Pen([string]$Hex, [float]$Width = 1) {
    return [System.Drawing.Pen]::new((Get-Color $Hex), $Width)
}

function New-AlphaPen([int]$Alpha, [string]$Hex, [float]$Width = 1) {
    $base = Get-Color $Hex
    return [System.Drawing.Pen]::new(
        [System.Drawing.Color]::FromArgb($Alpha, $base.R, $base.G, $base.B),
        $Width
    )
}

function New-RoundRectPath([float]$X, [float]$Y, [float]$Width, [float]$Height, [float]$Radius) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $Radius * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

$size = 512
$bitmap = [System.Drawing.Bitmap]::new(
    $size,
    $size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.Color]::Transparent)

$shadowPath = New-RoundRectPath 50 58 412 412 86
$shadowBrush = New-AlphaBrush 56 '#17201C'
$graphics.FillPath($shadowBrush, $shadowPath)
$shadowBrush.Dispose()
$shadowPath.Dispose()

$backgroundPath = New-RoundRectPath 42 42 412 412 86
$backgroundBrush = New-Brush '#0F8B63'
$graphics.FillPath($backgroundBrush, $backgroundPath)
$backgroundBrush.Dispose()

$ringPen = New-AlphaPen 235 '#F8F7F1' 28
$graphics.DrawArc($ringPen, 126, 126, 260, 260, 18, 250)
$ringPen.Dispose()

$ringAccentPen = New-Pen '#F7C948' 30
$ringAccentPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$ringAccentPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawArc($ringAccentPen, 126, 126, 260, 260, 304, 48)
$ringAccentPen.Dispose()

$centerBrush = New-Brush '#F8F7F1'
$graphics.FillEllipse($centerBrush, 204, 204, 104, 104)
$centerBrush.Dispose()

$centerPen = New-AlphaPen 95 '#17201C' 5
$graphics.DrawEllipse($centerPen, 204, 204, 104, 104)
$centerPen.Dispose()

$pencilBody = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pencilBody.AddPolygon(@(
    [System.Drawing.PointF]::new(160, 322),
    [System.Drawing.PointF]::new(320, 154),
    [System.Drawing.PointF]::new(363, 197),
    [System.Drawing.PointF]::new(203, 365)
))
$pencilShadow = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pencilShadow.AddPolygon(@(
    [System.Drawing.PointF]::new(173, 333),
    [System.Drawing.PointF]::new(333, 165),
    [System.Drawing.PointF]::new(376, 208),
    [System.Drawing.PointF]::new(216, 376)
))

$pencilShadowBrush = New-AlphaBrush 66 '#17201C'
$graphics.FillPath($pencilShadowBrush, $pencilShadow)
$pencilShadowBrush.Dispose()
$pencilShadow.Dispose()

$pencilBrush = New-Brush '#F8F7F1'
$graphics.FillPath($pencilBrush, $pencilBody)
$pencilBrush.Dispose()

$highlightPen = New-AlphaPen 170 '#FFFFFF' 8
$highlightPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$highlightPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($highlightPen, 192, 319, 316, 190)
$highlightPen.Dispose()

$tipPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$tipPath.AddPolygon(@(
    [System.Drawing.PointF]::new(320, 154),
    [System.Drawing.PointF]::new(402, 115),
    [System.Drawing.PointF]::new(363, 197)
))
$tipBrush = New-Brush '#F7C948'
$graphics.FillPath($tipBrush, $tipPath)
$tipBrush.Dispose()

$leadPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$leadPath.AddPolygon(@(
    [System.Drawing.PointF]::new(374, 128),
    [System.Drawing.PointF]::new(402, 115),
    [System.Drawing.PointF]::new(389, 143)
))
$leadBrush = New-Brush '#17201C'
$graphics.FillPath($leadBrush, $leadPath)
$leadBrush.Dispose()
$leadPath.Dispose()

$eraserPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$eraserPath.AddPolygon(@(
    [System.Drawing.PointF]::new(160, 322),
    [System.Drawing.PointF]::new(203, 365),
    [System.Drawing.PointF]::new(169, 398),
    [System.Drawing.PointF]::new(126, 356)
))
$eraserBrush = New-Brush '#E44835'
$graphics.FillPath($eraserBrush, $eraserPath)
$eraserBrush.Dispose()
$eraserPath.Dispose()

$bandPen = New-AlphaPen 210 '#17201C' 4
$graphics.DrawLine($bandPen, 160, 322, 203, 365)
$graphics.DrawLine($bandPen, 320, 154, 363, 197)
$bandPen.Dispose()

$dotBrush = New-Brush '#F7C948'
$graphics.FillEllipse($dotBrush, 335, 330, 42, 42)
$dotBrush.Dispose()

$pointerPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pointerPath.AddPolygon(@(
    [System.Drawing.PointF]::new(256, 96),
    [System.Drawing.PointF]::new(222, 158),
    [System.Drawing.PointF]::new(290, 158)
))
$pointerBrush = New-Brush '#E44835'
$graphics.FillPath($pointerBrush, $pointerPath)
$pointerBrush.Dispose()
$pointerPath.Dispose()

$backgroundPath.Dispose()
$pencilBody.Dispose()
$tipPath.Dispose()

$directory = Split-Path -Parent $OutPath
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Force $directory | Out-Null
}

$bitmap.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$bitmap.Dispose()

Write-Output (Resolve-Path $OutPath)
