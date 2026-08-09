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
    return $pen
}

function New-RoundedRectanglePath($x, $y, $width, $height, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
    $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Add-RoundedRectangle($graphics, $brush, $x, $y, $width, $height, $radius) {
    $path = New-RoundedRectanglePath $x $y $width $height $radius
    $graphics.FillPath($brush, $path)
    $path.Dispose()
}

function Add-Arrow($graphics, $x, $y, $size, $direction, $hex) {
    $pen = New-Pen $hex ([Math]::Max(2, $size * 0.11))
    $brush = New-Brush $hex
    $half = $size / 2
    $shaft = $size * 0.22
    $head = $size * 0.24

    switch ($direction) {
        "right" {
            $graphics.DrawLine($pen, $x - $shaft, $y, $x + $shaft, $y)
            $points = @(
                [System.Drawing.PointF]::new($x + $half - $head, $y - $head),
                [System.Drawing.PointF]::new($x + $half, $y),
                [System.Drawing.PointF]::new($x + $half - $head, $y + $head)
            )
        }
        "left" {
            $graphics.DrawLine($pen, $x + $shaft, $y, $x - $shaft, $y)
            $points = @(
                [System.Drawing.PointF]::new($x - $half + $head, $y - $head),
                [System.Drawing.PointF]::new($x - $half, $y),
                [System.Drawing.PointF]::new($x - $half + $head, $y + $head)
            )
        }
        "down" {
            $graphics.DrawLine($pen, $x, $y - $shaft, $x, $y + $shaft)
            $points = @(
                [System.Drawing.PointF]::new($x - $head, $y + $half - $head),
                [System.Drawing.PointF]::new($x, $y + $half),
                [System.Drawing.PointF]::new($x + $head, $y + $half - $head)
            )
        }
        default {
            $graphics.DrawLine($pen, $x, $y + $shaft, $x, $y - $shaft)
            $points = @(
                [System.Drawing.PointF]::new($x - $head, $y - $half + $head),
                [System.Drawing.PointF]::new($x, $y - $half),
                [System.Drawing.PointF]::new($x + $head, $y - $half + $head)
            )
        }
    }

    $graphics.FillPolygon($brush, $points)
    $pen.Dispose()
    $brush.Dispose()
}

function New-ArrowPuzzleIcon($path, $size) {
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#4B68A5"))

    $scale = $size / 192.0
    $accentBrush = New-Brush "#FFC531"
    $whiteBrush = New-Brush "#FFFFFF"
    $shadowBrush = New-Brush "#2E477C"

    Add-RoundedRectangle $graphics $shadowBrush (18 * $scale) (24 * $scale) (156 * $scale) (150 * $scale) (28 * $scale)
    Add-RoundedRectangle $graphics $whiteBrush (16 * $scale) (18 * $scale) (156 * $scale) (150 * $scale) (28 * $scale)

    $tile = 48 * $scale
    $radius = 12 * $scale
    Add-RoundedRectangle $graphics $accentBrush (38 * $scale) (38 * $scale) $tile $tile $radius
    Add-RoundedRectangle $graphics $whiteBrush (106 * $scale) (38 * $scale) $tile $tile $radius
    Add-RoundedRectangle $graphics $whiteBrush (38 * $scale) (106 * $scale) $tile $tile $radius
    Add-RoundedRectangle $graphics $accentBrush (106 * $scale) (106 * $scale) $tile $tile $radius

    Add-Arrow $graphics (62 * $scale) (62 * $scale) (28 * $scale) "right" "#4B68A5"
    Add-Arrow $graphics (130 * $scale) (62 * $scale) (28 * $scale) "down" "#4B68A5"
    Add-Arrow $graphics (62 * $scale) (130 * $scale) (28 * $scale) "up" "#4B68A5"
    Add-Arrow $graphics (130 * $scale) (130 * $scale) (28 * $scale) "left" "#4B68A5"

    $directory = Split-Path -Parent $path
    if (!(Test-Path $directory)) {
        New-Item -ItemType Directory -Force $directory | Out-Null
    }
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $accentBrush.Dispose()
    $whiteBrush.Dispose()
    $shadowBrush.Dispose()
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
    New-ArrowPuzzleIcon (Join-Path $Root $entry.Key) $entry.Value
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
    New-ArrowPuzzleIcon (Join-Path $Root $entry.Key) $entry.Value
}

Write-Host "Generated Arrow Puzzle launcher icons."
