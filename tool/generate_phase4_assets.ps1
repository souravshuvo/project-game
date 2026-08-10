Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

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

function Add-SignalReefIcon($path, $size) {
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#07131E"))

    $scale = $size / 192.0
    $panelBrush = New-Brush "#102A34"
    $shipBrush = New-Brush "#50D6C7"
    $coreBrush = New-Brush "#FFFFFF"
    $trailPen = New-Pen "#FFC857" (8 * $scale)
    $currentPen = New-Pen "#B7FFF6" (3 * $scale)

    $graphics.FillEllipse($panelBrush, 12 * $scale, 12 * $scale, 168 * $scale, 168 * $scale)

    $currentPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $currentPath.AddBezier(
        [System.Drawing.PointF]::new(20 * $scale, 58 * $scale),
        [System.Drawing.PointF]::new(70 * $scale, 34 * $scale),
        [System.Drawing.PointF]::new(126 * $scale, 82 * $scale),
        [System.Drawing.PointF]::new(174 * $scale, 56 * $scale)
    )
    $graphics.DrawPath($currentPen, $currentPath)
    $currentPath.Dispose()

    $ship = New-Object System.Drawing.Drawing2D.GraphicsPath
    $ship.AddPolygon(@(
        [System.Drawing.PointF]::new(96 * $scale, 28 * $scale),
        [System.Drawing.PointF]::new(142 * $scale, 136 * $scale),
        [System.Drawing.PointF]::new(96 * $scale, 164 * $scale),
        [System.Drawing.PointF]::new(50 * $scale, 136 * $scale)
    ))
    $graphics.FillPath($shipBrush, $ship)
    $ship.Dispose()

    $graphics.FillEllipse($coreBrush, 82 * $scale, 74 * $scale, 28 * $scale, 28 * $scale)
    $graphics.DrawLine($trailPen, 96 * $scale, 150 * $scale, 96 * $scale, 184 * $scale)

    $directory = Split-Path -Parent $path
    if (!(Test-Path $directory)) {
        New-Item -ItemType Directory -Force $directory | Out-Null
    }
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $panelBrush.Dispose()
    $shipBrush.Dispose()
    $coreBrush.Dispose()
    $trailPen.Dispose()
    $currentPen.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$androidIcons = @{
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
}

foreach ($entry in $androidIcons.GetEnumerator()) {
    Add-SignalReefIcon (Join-Path $Root $entry.Key) $entry.Value
}

$iosIcons = @{
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png" = 20
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png" = 40
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png" = 60
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png" = 29
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png" = 58
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png" = 87
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png" = 40
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png" = 80
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png" = 120
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png" = 120
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" = 180
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png" = 76
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png" = 152
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png" = 167
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" = 1024
}

foreach ($entry in $iosIcons.GetEnumerator()) {
    Add-SignalReefIcon (Join-Path $Root $entry.Key) $entry.Value
}

Write-Host "Generated Signal Reef launcher icons."
