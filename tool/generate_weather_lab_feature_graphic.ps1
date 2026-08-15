param(
  [string]$OutputPath = "store_assets/feature_graphic/feature-graphic.png"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 500

function New-Color {
  param(
    [string]$Hex,
    [int]$Alpha = 255
  )

  $value = $Hex.TrimStart("#")
  return [System.Drawing.Color]::FromArgb(
    $Alpha,
    [Convert]::ToInt32($value.Substring(0, 2), 16),
    [Convert]::ToInt32($value.Substring(2, 2), 16),
    [Convert]::ToInt32($value.Substring(4, 2), 16)
  )
}

function New-RoundedRectPath {
  param(
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [float]$Radius
  )

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $diameter = $Radius * 2
  $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
  $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
  $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function Draw-Wave {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Y,
    [System.Drawing.Pen]$Pen,
    [float]$StartX = 0,
    [float]$EndX = 1024,
    [float]$Amplitude = 14
  )

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.StartFigure()
  $x = $StartX
  $path.AddBezier($x, $Y, $x + 70, $Y - $Amplitude, $x + 120, $Y + $Amplitude, $x + 190, $Y)
  $x += 190
  while ($x -lt $EndX) {
    $path.AddBezier($x, $Y, $x + 70, $Y - $Amplitude, $x + 120, $Y + $Amplitude, $x + 190, $Y)
    $x += 190
  }
  $Graphics.DrawPath($Pen, $path)
  $path.Dispose()
}

function Draw-DropletIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Brush]$Brush
  )

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddBezier($Cx, $Cy - $Size, $Cx + ($Size * 0.85), $Cy - ($Size * 0.10), $Cx + ($Size * 0.55), $Cy + $Size, $Cx, $Cy + $Size)
  $path.AddBezier($Cx, $Cy + $Size, $Cx - ($Size * 0.55), $Cy + $Size, $Cx - ($Size * 0.85), $Cy - ($Size * 0.10), $Cx, $Cy - $Size)
  $path.CloseFigure()
  $Graphics.FillPath($Brush, $path)
  $path.Dispose()
}

function Draw-SunIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Brush]$Brush,
    [System.Drawing.Pen]$Pen
  )

  $Graphics.FillEllipse($Brush, $Cx - $Size * 0.45, $Cy - $Size * 0.45, $Size * 0.90, $Size * 0.90)
  for ($i = 0; $i -lt 8; $i++) {
    $angle = ($i * 45) * [Math]::PI / 180
    $x1 = $Cx + [Math]::Cos($angle) * ($Size * 0.68)
    $y1 = $Cy + [Math]::Sin($angle) * ($Size * 0.68)
    $x2 = $Cx + [Math]::Cos($angle) * ($Size * 1.02)
    $y2 = $Cy + [Math]::Sin($angle) * ($Size * 1.02)
    $Graphics.DrawLine($Pen, [float]$x1, [float]$y1, [float]$x2, [float]$y2)
  }
}

function Draw-MistIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Pen]$Pen
  )

  for ($i = -1; $i -le 1; $i++) {
    $y = $Cy + ($i * $Size * 0.32)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddBezier($Cx - $Size, $y, $Cx - ($Size * 0.40), $y - ($Size * 0.25), $Cx + ($Size * 0.15), $y + ($Size * 0.25), $Cx + $Size, $y)
    $Graphics.DrawPath($Pen, $path)
    $path.Dispose()
  }
}

function Draw-CloudIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Brush]$Brush
  )

  $Graphics.FillEllipse($Brush, $Cx - $Size * 0.85, $Cy - $Size * 0.08, $Size * 0.70, $Size * 0.55)
  $Graphics.FillEllipse($Brush, $Cx - $Size * 0.45, $Cy - $Size * 0.35, $Size * 0.82, $Size * 0.82)
  $Graphics.FillEllipse($Brush, $Cx + $Size * 0.12, $Cy - $Size * 0.02, $Size * 0.66, $Size * 0.55)
  $Graphics.FillRectangle($Brush, $Cx - $Size * 0.65, $Cy + $Size * 0.18, $Size * 1.28, $Size * 0.28)
}

function Draw-FrostIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Pen]$Pen
  )

  for ($i = 0; $i -lt 3; $i++) {
    $angle = ($i * 60) * [Math]::PI / 180
    $dx = [Math]::Cos($angle) * $Size
    $dy = [Math]::Sin($angle) * $Size
    $Graphics.DrawLine($Pen, [float]($Cx - $dx), [float]($Cy - $dy), [float]($Cx + $dx), [float]($Cy + $dy))
  }
}

function Draw-WeatherIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [string]$Kind,
    [float]$Cx,
    [float]$Cy,
    [float]$Size
  )

  $iconBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 200)
  $iconPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#FFFFFF" 210), [float]([Math]::Max(2.0, $Size * 0.16)))
  $iconPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $iconPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  switch ($Kind) {
    "rain" { Draw-DropletIcon $Graphics $Cx $Cy ($Size * 0.52) $iconBrush }
    "sun" { Draw-SunIcon $Graphics $Cx $Cy ($Size * 0.52) $iconBrush $iconPen }
    "mist" { Draw-MistIcon $Graphics $Cx $Cy ($Size * 0.56) $iconPen }
    "cloud" { Draw-CloudIcon $Graphics $Cx $Cy ($Size * 0.54) $iconBrush }
    "frost" { Draw-FrostIcon $Graphics $Cx $Cy ($Size * 0.56) $iconPen }
  }

  $iconPen.Dispose()
  $iconBrush.Dispose()
}

function Draw-Vessel {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [object[]]$Layers
  )

  $shadowPath = New-RoundedRectPath ($X + 8) ($Y + 11) $Width $Height 26
  $shadowBrush = New-Object System.Drawing.SolidBrush (New-Color "#214C75" 24)
  $Graphics.FillPath($shadowBrush, $shadowPath)

  $outerPath = New-RoundedRectPath $X $Y $Width $Height 26
  $glassBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 138)
  $glassPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#386FA4" 150), 3.5)
  $Graphics.FillPath($glassBrush, $outerPath)

  $innerX = $X + 10
  $innerY = $Y + 24
  $innerW = $Width - 20
  $innerH = $Height - 34
  $clipPath = New-RoundedRectPath $innerX $innerY $innerW $innerH 17
  $state = $Graphics.Save()
  $Graphics.SetClip($clipPath)

  $capacity = 4.0
  $layerHeight = $innerH / $capacity
  for ($i = 0; $i -lt $Layers.Count; $i++) {
    $layer = $Layers[$i]
    $layerY = $innerY + $innerH - (($i + 1) * $layerHeight)
    $rect = New-Object System.Drawing.RectangleF $innerX, $layerY, $innerW, ($layerHeight + 0.7)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, (New-Color $layer.Color 235), (New-Color $layer.Color 255), 90
    $Graphics.FillRectangle($brush, $rect)
    $shineBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 42)
    $Graphics.FillEllipse($shineBrush, $innerX + 7, $layerY + 6, $innerW - 14, 12)
    Draw-WeatherIcon $Graphics $layer.Kind ($innerX + $innerW / 2) ($layerY + $layerHeight / 2) ([Math]::Min($innerW, $layerHeight) * 0.52)
    $shineBrush.Dispose()
    $brush.Dispose()
  }

  $Graphics.Restore($state)

  $highlightPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#FFFFFF" 170), 2.2)
  $Graphics.DrawLine($highlightPen, $X + 20, $Y + 34, $X + 20, $Y + $Height - 36)
  $Graphics.DrawPath($glassPen, $outerPath)

  $rimPath = New-RoundedRectPath ($X + 5) ($Y - 4) ($Width - 10) 15 7
  $rimBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 190)
  $rimPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#386FA4" 115), 2.0)
  $Graphics.FillPath($rimBrush, $rimPath)
  $Graphics.DrawPath($rimPen, $rimPath)

  $rimPen.Dispose()
  $rimBrush.Dispose()
  $highlightPen.Dispose()
  $glassPen.Dispose()
  $glassBrush.Dispose()
  $shadowBrush.Dispose()
  $rimPath.Dispose()
  $clipPath.Dispose()
  $outerPath.Dispose()
  $shadowPath.Dispose()
}

$palette = @{
  ink = "#18212F"
  mutedInk = "#637084"
  canvas = "#F3F7FB"
  wash = "#EAF3F8"
  line = "#D8E3EC"
  primary = "#386FA4"
  primaryDark = "#214C75"
  rain = "#2F80B9"
  sun = "#F6C65B"
  mist = "#88B4AE"
  cloud = "#7B6FB3"
  frost = "#9FDDE7"
}

$bitmap = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

$canvasRect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
$background = New-Object System.Drawing.Drawing2D.LinearGradientBrush $canvasRect, (New-Color $palette.canvas), (New-Color "#FFFFFF"), 0
$graphics.FillRectangle($background, $canvasRect)

$washBrush = New-Object System.Drawing.SolidBrush (New-Color $palette.wash 205)
$graphics.FillEllipse($washBrush, 500, -210, 650, 650)
$graphics.FillEllipse($washBrush, -260, 250, 520, 330)

$wavePen = New-Object System.Drawing.Pen -ArgumentList @((New-Color $palette.line 95), 2.0)
Draw-Wave $graphics 85 $wavePen 40 990 10
Draw-Wave $graphics 425 $wavePen 0 720 12
Draw-Wave $graphics 455 $wavePen 370 1040 8

$sunPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color $palette.sun 105), 3.0)
$sunPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$sunPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$sunBrush = New-Object System.Drawing.SolidBrush (New-Color $palette.sun 60)
$graphics.FillEllipse($sunBrush, 92, 72, 62, 62)
for ($i = 0; $i -lt 8; $i++) {
  $angle = ($i * 45) * [Math]::PI / 180
  $x1 = 123 + [Math]::Cos($angle) * 43
  $y1 = 103 + [Math]::Sin($angle) * 43
  $x2 = 123 + [Math]::Cos($angle) * 58
  $y2 = 103 + [Math]::Sin($angle) * 58
  $graphics.DrawLine($sunPen, [float]$x1, [float]$y1, [float]$x2, [float]$y2)
}

$titleSize = 51
$titleText = "Weather Lab Sort"
$titleFont = $null
do {
  if ($titleFont) {
    $titleFont.Dispose()
  }
  $titleFont = New-Object System.Drawing.Font "Segoe UI", $titleSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $titleSize -= 1
} while (($graphics.MeasureString($titleText, $titleFont).Width -gt 410) -and ($titleSize -gt 34))

$titleBrush = New-Object System.Drawing.SolidBrush (New-Color $palette.ink)
$titlePoint = New-Object System.Drawing.PointF 70, 194
$graphics.DrawString($titleText, $titleFont, $titleBrush, $titlePoint)

$accentPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color $palette.primary 130), 4.0)
$accentPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$accentPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$accentPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$accentPath.AddBezier(72, 277, 165, 300, 264, 247, 382, 272)
$graphics.DrawPath($accentPen, $accentPath)

$pourPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$pourPath.AddBezier(625, 133, 664, 92, 729, 104, 760, 145)
$pourPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color $palette.primary 125), 8.0)
$pourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawPath($pourPen, $pourPath)
$dropBrush = New-Object System.Drawing.SolidBrush (New-Color $palette.primary 145)
Draw-DropletIcon $graphics 759 151 9 $dropBrush

$rain = [pscustomobject]@{ Kind = "rain"; Color = $palette.rain }
$sun = [pscustomobject]@{ Kind = "sun"; Color = $palette.sun }
$mist = [pscustomobject]@{ Kind = "mist"; Color = $palette.mist }
$cloud = [pscustomobject]@{ Kind = "cloud"; Color = $palette.cloud }
$frost = [pscustomobject]@{ Kind = "frost"; Color = $palette.frost }

Draw-Vessel $graphics 500 158 72 245 @($rain, $sun, $mist)
Draw-Vessel $graphics 590 128 78 275 @($frost, $cloud, $rain, $sun)
Draw-Vessel $graphics 690 152 72 251 @($mist, $frost, $cloud)
Draw-Vessel $graphics 780 118 78 285 @($sun, $rain, $cloud, $frost)
Draw-Vessel $graphics 880 160 66 243 @($cloud, $mist)

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
  New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$dropBrush.Dispose()
$pourPen.Dispose()
$pourPath.Dispose()
$accentPath.Dispose()
$accentPen.Dispose()
$titleBrush.Dispose()
$titleFont.Dispose()
$sunBrush.Dispose()
$sunPen.Dispose()
$wavePen.Dispose()
$washBrush.Dispose()
$background.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Generated $OutputPath"
