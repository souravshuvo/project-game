Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$PlayStoreIconPath = Join-Path $Root "store_assets/app_icon/play-store-icon.png"
$IconSourcePath = Join-Path $Root "store_assets/app_icon/icon-source-1024.png"

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

function Add-X($graphics, $x, $y, $size, $hex) {
    $pen = New-Pen $hex ([Math]::Max(2, $size * 0.12))
    $inset = $size * 0.25
    $graphics.DrawLine($pen, $x + $inset, $y + $inset, $x + $size - $inset, $y + $size - $inset)
    $graphics.DrawLine($pen, $x + $size - $inset, $y + $inset, $x + $inset, $y + $size - $inset)
    $pen.Dispose()
}

function Add-O($graphics, $x, $y, $size, $hex) {
    $pen = New-Pen $hex ([Math]::Max(2, $size * 0.11))
    $inset = $size * 0.24
    $graphics.DrawEllipse($pen, $x + $inset, $y + $inset, $size - ($inset * 2), $size - ($inset * 2))
    $pen.Dispose()
}

function New-TikTakToeIcon($path, $size, [bool] $WithAlpha) {
    $pixelFormat = if ($WithAlpha) {
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    } else {
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    }
    $bitmap = New-Object System.Drawing.Bitmap $size, $size, $pixelFormat
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#17151F"))

    $scale = $size / 192.0
    $panelBrush = New-Brush "#F8F2E7"
    $goldBrush = New-Brush "#E9B64E"
    $shadowBrush = New-Brush "#24202E"

    Add-RoundedRectangle $graphics $shadowBrush (24 * $scale) (26 * $scale) (148 * $scale) (148 * $scale) (22 * $scale)
    Add-RoundedRectangle $graphics $goldBrush (20 * $scale) (20 * $scale) (152 * $scale) (152 * $scale) (18 * $scale)
    Add-RoundedRectangle $graphics $panelBrush (28 * $scale) (28 * $scale) (136 * $scale) (136 * $scale) (12 * $scale)

    $linePen = New-Pen "#24202E" ([Math]::Max(1, 5 * $scale))
    $graphics.DrawLine($linePen, 73 * $scale, 30 * $scale, 73 * $scale, 162 * $scale)
    $graphics.DrawLine($linePen, 119 * $scale, 30 * $scale, 119 * $scale, 162 * $scale)
    $graphics.DrawLine($linePen, 30 * $scale, 73 * $scale, 162 * $scale, 73 * $scale)
    $graphics.DrawLine($linePen, 30 * $scale, 119 * $scale, 162 * $scale, 119 * $scale)
    $linePen.Dispose()

    Add-X $graphics (34 * $scale) (34 * $scale) (38 * $scale) "#E9B64E"
    Add-O $graphics (120 * $scale) (120 * $scale) (38 * $scale) "#4DB7A8"

    $sparkPen = New-Pen "#E9B64E" ([Math]::Max(1, 4 * $scale))
    $graphics.DrawLine($sparkPen, 128 * $scale, 52 * $scale, 154 * $scale, 52 * $scale)
    $graphics.DrawLine($sparkPen, 141 * $scale, 39 * $scale, 141 * $scale, 65 * $scale)
    $sparkPen.Dispose()

    $directory = Split-Path -Parent $path
    if (!(Test-Path $directory)) {
        New-Item -ItemType Directory -Force $directory | Out-Null
    }
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $panelBrush.Dispose()
    $goldBrush.Dispose()
    $shadowBrush.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

New-TikTakToeIcon $PlayStoreIconPath 512 $true
New-TikTakToeIcon $IconSourcePath 1024 $false

$androidIcons = @{
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
}

foreach ($entry in $androidIcons.GetEnumerator()) {
    New-TikTakToeIcon (Join-Path $Root $entry.Key) $entry.Value $false
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
    New-TikTakToeIcon (Join-Path $Root $entry.Key) $entry.Value $false
}

Write-Host "Generated Tik Tak Toe Play Store and launcher icons."
