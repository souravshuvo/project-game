param(
    [string]$OutPath = (Join-Path $PSScriptRoot '..\store_assets\pencil_pitch_feature_graphic_1024x500.jpg')
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

function Draw-CenteredString(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [System.Drawing.Font]$Font,
    [System.Drawing.Brush]$Brush,
    [float]$CenterX,
    [float]$CenterY
) {
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = [System.Drawing.RectangleF]::new($CenterX - 80, $CenterY - 24, 160, 48)
    $Graphics.DrawString($Text, $Font, $Brush, $rect, $format)
    $format.Dispose()
}

function Draw-Chip(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [string]$Fill,
    [string]$TextColor,
    [System.Drawing.Font]$Font
) {
    $path = New-RoundRectPath $X $Y $Width $Height 18
    $brush = New-Brush $Fill
    $pen = New-AlphaPen 80 '#17201C' 1.5
    $Graphics.FillPath($brush, $path)
    $Graphics.DrawPath($pen, $path)
    $textBrush = New-Brush $TextColor
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $Graphics.DrawString($Text, $Font, $textBrush, [System.Drawing.RectangleF]::new($X, $Y + 1, $Width, $Height), $format)
    $format.Dispose()
    $textBrush.Dispose()
    $pen.Dispose()
    $brush.Dispose()
    $path.Dispose()
}

$width = 1024
$height = 500
$bitmap = [System.Drawing.Bitmap]::new(
    $width,
    $height,
    [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear((Get-Color '#F8F7F1'))

$paperLinePen = New-AlphaPen 85 '#DAD4C4' 1
for ($y = 42; $y -lt $height; $y += 34) {
    $graphics.DrawLine($paperLinePen, 0, $y, $width, $y)
}
$paperLinePen.Dispose()

$marginPen = New-AlphaPen 95 '#E44835' 2
$graphics.DrawLine($marginPen, 72, 0, 72, $height)
$marginPen.Dispose()

$shadow = New-AlphaBrush 36 '#17201C'
$shadowPath = New-RoundRectPath 528 62 430 378 38
$graphics.FillPath($shadow, $shadowPath)
$shadow.Dispose()
$shadowPath.Dispose()

$greenPanel = New-RoundRectPath 520 54 430 378 38
$greenBrush = New-Brush '#0F8B63'
$graphics.FillPath($greenBrush, $greenPanel)
$greenBrush.Dispose()

$arcPen = New-AlphaPen 80 '#F8F7F1' 2.5
$graphics.DrawArc($arcPen, 750, 80, 170, 170, 205, 95)
$graphics.DrawArc($arcPen, 557, 332, 135, 135, 20, 110)
$arcPen.Dispose()

$titleFont = [System.Drawing.Font]::new('Segoe UI', 48, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$subtitleFont = [System.Drawing.Font]::new('Segoe UI', 25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$chipFont = [System.Drawing.Font]::new('Segoe UI', 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$wheelFont = [System.Drawing.Font]::new('Segoe UI', 18, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$smallFont = [System.Drawing.Font]::new('Segoe UI', 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)

$textShadow = New-AlphaBrush 70 '#17201C'
$white = New-Brush '#F8F7F1'
$yellow = New-Brush '#F7C948'

$graphics.DrawString('Pencil Pitch', $titleFont, $textShadow, [System.Drawing.PointF]::new(585, 141))
$graphics.DrawString('Pencil Pitch', $titleFont, $white, [System.Drawing.PointF]::new(580, 136))
$graphics.DrawString('Offline Pen Cricket', $subtitleFont, $yellow, [System.Drawing.PointF]::new(581, 218))

Draw-Chip $graphics '4' 586 300 58 44 '#F8F7F1' '#17201C' $chipFont
Draw-Chip $graphics '6' 658 300 58 44 '#F7C948' '#17201C' $chipFont
Draw-Chip $graphics 'W' 730 300 58 44 '#FFF1F1' '#9B1C1C' $chipFont
Draw-Chip $graphics 'Wd' 802 300 64 44 '#E7F8F0' '#0F8B63' $chipFont
Draw-Chip $graphics 'Nb' 624 360 64 44 '#FFF6DA' '#8A5200' $chipFont
Draw-Chip $graphics 'Target' 704 360 122 44 '#F8F7F1' '#17201C' $smallFont

$greenPanel.Dispose()

$pencilPen = New-Pen '#F7C948' 30
$pencilPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pencilPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Triangle
$graphics.DrawLine($pencilPen, 88, 415, 430, 344)
$pencilPen.Dispose()

$pencilHighlight = New-AlphaPen 165 '#F8F7F1' 4
$graphics.DrawLine($pencilHighlight, 112, 406, 394, 347)
$pencilHighlight.Dispose()

$eraserPen = New-Pen '#EF476F' 18
$eraserPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$eraserPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($eraserPen, 84, 416, 124, 408)
$eraserPen.Dispose()

$centerX = 318
$centerY = 235
$radius = 166
$wheelRect = [System.Drawing.Rectangle]::new($centerX - $radius, $centerY - $radius, $radius * 2, $radius * 2)
$segmentLabels = @('0', '1', '4', 'W', '2', 'Wd', '6', '0', '1', 'Nb', '3', '4', 'W', '2')
$segmentColors = @(
    '#FFD166', '#65D6AD', '#EF476F', '#243B53', '#7BDFF2', '#FF9F1C', '#06D6A0',
    '#FDE74C', '#90BE6D', '#FF6B6B', '#4D96FF', '#F9844A', '#3D348B', '#B8F2E6'
)
$sweep = 360 / $segmentLabels.Count
for ($i = 0; $i -lt $segmentLabels.Count; $i++) {
    $brush = New-Brush $segmentColors[$i]
    $graphics.FillPie($brush, $wheelRect, -90 + ($i * $sweep), $sweep + 0.35)
    $brush.Dispose()
}

$wheelStroke = New-Pen '#17201C' 5
$graphics.DrawEllipse($wheelStroke, $wheelRect)
$wheelStroke.Dispose()

$spokePen = New-AlphaPen 120 '#17201C' 1.5
for ($i = 0; $i -lt $segmentLabels.Count; $i++) {
    $angle = (-90 + ($i * $sweep)) * [Math]::PI / 180
    $x2 = $centerX + [Math]::Cos($angle) * $radius
    $y2 = $centerY + [Math]::Sin($angle) * $radius
    $graphics.DrawLine($spokePen, $centerX, $centerY, [float]$x2, [float]$y2)
}
$spokePen.Dispose()

for ($i = 0; $i -lt $segmentLabels.Count; $i++) {
    $angle = (-90 + (($i + 0.5) * $sweep)) * [Math]::PI / 180
    $labelRadius = $radius * 0.67
    $x = $centerX + [Math]::Cos($angle) * $labelRadius
    $y = $centerY + [Math]::Sin($angle) * $labelRadius
    $darkText = @('#FFD166', '#65D6AD', '#7BDFF2', '#FDE74C', '#90BE6D', '#B8F2E6', '#06D6A0', '#FF9F1C') -contains $segmentColors[$i]
    $labelBrush = if ($darkText) { New-Brush '#17201C' } else { New-Brush '#F8F7F1' }
    Draw-CenteredString $graphics $segmentLabels[$i] $wheelFont $labelBrush $x $y
    $labelBrush.Dispose()
}

$centerBrush = New-Brush '#F8F7F1'
$graphics.FillEllipse($centerBrush, $centerX - 48, $centerY - 48, 96, 96)
$centerBrush.Dispose()
$centerStroke = New-Pen '#17201C' 3
$graphics.DrawEllipse($centerStroke, $centerX - 48, $centerY - 48, 96, 96)
$centerStroke.Dispose()
$spinTextBrush = New-Brush '#0F8B63'
Draw-CenteredString $graphics 'Spin' $smallFont $spinTextBrush $centerX $centerY
$spinTextBrush.Dispose()

$pointerBrush = New-Brush '#E44835'
$pointerPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pointerPath.AddPolygon(@(
    [System.Drawing.PointF]::new($centerX, $centerY - $radius - 28),
    [System.Drawing.PointF]::new($centerX - 28, $centerY - $radius + 22),
    [System.Drawing.PointF]::new($centerX + 28, $centerY - $radius + 22)
))
$graphics.FillPath($pointerBrush, $pointerPath)
$pointerBrush.Dispose()
$pointerPath.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' } |
    Select-Object -First 1
$encoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = [System.Drawing.Imaging.EncoderParameters]::new(1)
$encoderParams.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new($encoder, [int64]92)

$directory = Split-Path -Parent $OutPath
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Force $directory | Out-Null
}

$bitmap.Save($OutPath, $codec, $encoderParams)

$encoderParams.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
$titleFont.Dispose()
$subtitleFont.Dispose()
$chipFont.Dispose()
$wheelFont.Dispose()
$smallFont.Dispose()
$textShadow.Dispose()
$white.Dispose()
$yellow.Dispose()

Write-Output (Resolve-Path $OutPath)
