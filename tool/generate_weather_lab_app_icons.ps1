param(
  [string]$StoreIconDirectory = "store_assets/app_icon",
  [switch]$SkipLauncherIcons
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

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

function Draw-DropletIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Size,
    [System.Drawing.Brush]$Brush
  )

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddBezier($Cx, $Cy - $Size, $Cx + ($Size * 0.82), $Cy - ($Size * 0.12), $Cx + ($Size * 0.55), $Cy + $Size, $Cx, $Cy + $Size)
  $path.AddBezier($Cx, $Cy + $Size, $Cx - ($Size * 0.55), $Cy + $Size, $Cx - ($Size * 0.82), $Cy - ($Size * 0.12), $Cx, $Cy - $Size)
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

  $Graphics.FillEllipse($Brush, $Cx - $Size * 0.42, $Cy - $Size * 0.42, $Size * 0.84, $Size * 0.84)
  for ($i = 0; $i -lt 8; $i++) {
    $angle = ($i * 45) * [Math]::PI / 180
    $x1 = $Cx + [Math]::Cos($angle) * ($Size * 0.65)
    $y1 = $Cy + [Math]::Sin($angle) * ($Size * 0.65)
    $x2 = $Cx + [Math]::Cos($angle) * ($Size * 0.94)
    $y2 = $Cy + [Math]::Sin($angle) * ($Size * 0.94)
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
    $y = $Cy + ($i * $Size * 0.34)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddBezier($Cx - $Size, $y, $Cx - ($Size * 0.42), $y - ($Size * 0.26), $Cx + ($Size * 0.12), $y + ($Size * 0.22), $Cx + $Size, $y)
    $Graphics.DrawPath($Pen, $path)
    $path.Dispose()
  }
}

function Draw-WeatherLayerIcon {
  param(
    [System.Drawing.Graphics]$Graphics,
    [string]$Kind,
    [float]$Cx,
    [float]$Cy,
    [float]$Size
  )

  $brush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 218)
  $pen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#FFFFFF" 220), [float]($Size * 0.14))
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  switch ($Kind) {
    "rain" { Draw-DropletIcon $Graphics $Cx $Cy ($Size * 0.48) $brush }
    "sun" { Draw-SunIcon $Graphics $Cx $Cy ($Size * 0.50) $brush $pen }
    "mist" { Draw-MistIcon $Graphics $Cx $Cy ($Size * 0.58) $pen }
  }

  $pen.Dispose()
  $brush.Dispose()
}

function New-WeatherLabIconBitmap {
  param(
    [int]$Size,
    [System.Drawing.Imaging.PixelFormat]$PixelFormat
  )

  $bitmap = New-Object System.Drawing.Bitmap $Size, $Size, $PixelFormat
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

  $scale = $Size / 1024.0
  $graphics.ScaleTransform($scale, $scale)

  $canvas = New-Object System.Drawing.Rectangle 0, 0, 1024, 1024
  $background = New-Object System.Drawing.Drawing2D.LinearGradientBrush $canvas, (New-Color "#214C75"), (New-Color "#386FA4"), 45
  $graphics.FillRectangle($background, $canvas)

  $glowBrush = New-Object System.Drawing.SolidBrush (New-Color "#9FDDE7" 34)
  $graphics.FillEllipse($glowBrush, 72, -140, 610, 530)
  $graphics.FillEllipse($glowBrush, 444, 550, 660, 560)

  $sparkPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#FFFFFF" 82), 8.0)
  $sparkPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $sparkPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $graphics.DrawLine($sparkPen, 178, 210, 238, 210)
  $graphics.DrawLine($sparkPen, 208, 180, 208, 240)
  $graphics.DrawLine($sparkPen, 806, 788, 860, 788)
  $graphics.DrawLine($sparkPen, 833, 760, 833, 816)

  $shadowPath = New-RoundedRectPath 316 154 392 712 112
  $shadowBrush = New-Object System.Drawing.SolidBrush (New-Color "#0F2437" 92)
  $graphics.TranslateTransform(26, 34)
  $graphics.FillPath($shadowBrush, $shadowPath)
  $graphics.ResetTransform()
  $graphics.ScaleTransform($scale, $scale)

  $outerPath = New-RoundedRectPath 316 154 392 712 112
  $glassBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 82)
  $outlinePen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#E8F4FC" 235), 18.0)
  $outlinePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $graphics.FillPath($glassBrush, $outerPath)

  $innerPath = New-RoundedRectPath 356 252 312 538 62
  $clipState = $graphics.Save()
  $graphics.SetClip($innerPath)

  $layerDefinitions = @(
    @{Kind = "rain"; Color = "#2F80B9"; Y = 648; Height = 142; IconY = 720},
    @{Kind = "sun"; Color = "#F6C65B"; Y = 506; Height = 142; IconY = 578},
    @{Kind = "mist"; Color = "#88B4AE"; Y = 364; Height = 142; IconY = 436}
  )

  foreach ($layer in $layerDefinitions) {
    $rect = New-Object System.Drawing.RectangleF 356, $layer.Y, 312, $layer.Height
    $layerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, (New-Color $layer.Color 242), (New-Color $layer.Color 255), 90
    $graphics.FillRectangle($layerBrush, $rect)

    $shineBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 46)
    $graphics.FillEllipse($shineBrush, 384, ($layer.Y + 20), 256, 28)
    Draw-WeatherLayerIcon $graphics $layer.Kind 512 $layer.IconY 78
    $shineBrush.Dispose()
    $layerBrush.Dispose()
  }

  $graphics.Restore($clipState)

  $highlightPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#FFFFFF" 150), 10.0)
  $highlightPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $highlightPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $graphics.DrawLine($highlightPen, 382, 248, 382, 726)
  $graphics.DrawPath($outlinePen, $outerPath)

  $rimPath = New-RoundedRectPath 376 102 272 106 46
  $rimBrush = New-Object System.Drawing.SolidBrush (New-Color "#FFFFFF" 238)
  $rimPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#D8E3EC" 240), 10.0)
  $graphics.FillPath($rimBrush, $rimPath)
  $graphics.DrawPath($rimPen, $rimPath)

  $capPath = New-RoundedRectPath 410 72 204 54 22
  $capBrush = New-Object System.Drawing.SolidBrush (New-Color "#F3F7FB" 255)
  $capPen = New-Object System.Drawing.Pen -ArgumentList @((New-Color "#C7DAE8" 255), 8.0)
  $graphics.FillPath($capBrush, $capPath)
  $graphics.DrawPath($capPen, $capPath)

  $innerPath.Dispose()
  $capPen.Dispose()
  $capBrush.Dispose()
  $capPath.Dispose()
  $rimPen.Dispose()
  $rimBrush.Dispose()
  $rimPath.Dispose()
  $highlightPen.Dispose()
  $outlinePen.Dispose()
  $glassBrush.Dispose()
  $outerPath.Dispose()
  $shadowBrush.Dispose()
  $shadowPath.Dispose()
  $sparkPen.Dispose()
  $glowBrush.Dispose()
  $background.Dispose()
  $graphics.Dispose()

  return $bitmap
}

function Save-Icon {
  param(
    [string]$Path,
    [int]$Size,
    [System.Drawing.Imaging.PixelFormat]$PixelFormat
  )

  $directory = Split-Path -Parent $Path
  if ($directory -and -not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
  }

  $bitmap = New-WeatherLabIconBitmap $Size $PixelFormat
  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

Save-Icon (Join-Path $StoreIconDirectory "weather-lab-sort-icon-source-1024.png") 1024 ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
Save-Icon (Join-Path $StoreIconDirectory "play-icon-512.png") 512 ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

if (-not $SkipLauncherIcons) {
  $androidIcons = @(
    @{ Path = "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"; Size = 48 },
    @{ Path = "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"; Size = 72 },
    @{ Path = "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"; Size = 96 },
    @{ Path = "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"; Size = 144 },
    @{ Path = "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"; Size = 192 }
  )

  foreach ($icon in $androidIcons) {
    Save-Icon $icon.Path $icon.Size ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  }

  $iosIcons = @(
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png"; Size = 20 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png"; Size = 40 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png"; Size = 60 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png"; Size = 29 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png"; Size = 58 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png"; Size = 87 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png"; Size = 40 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png"; Size = 80 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png"; Size = 120 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"; Size = 120 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"; Size = 180 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png"; Size = 76 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png"; Size = 152 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png"; Size = 167 },
    @{ Path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"; Size = 1024 }
  )

  foreach ($icon in $iosIcons) {
    Save-Icon $icon.Path $icon.Size ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  }
}

Write-Host "Generated Weather Lab Sort app icons."
