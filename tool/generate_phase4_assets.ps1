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

function Add-LabelTile($graphics, $x, $y, $size, $fillHex, $text) {
    $fillBrush = New-Brush $fillHex
    $linePen = New-Pen "#16443F" ([Math]::Max(1, $size * 0.035))
    $textBrush = New-Brush "#16443F"
    $font = New-Object System.Drawing.Font("Segoe UI", [Math]::Max(6, $size * 0.22), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

    Add-RoundedRectangle $graphics $fillBrush $x $y $size $size ([Math]::Max(3, $size * 0.18))

    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = [System.Drawing.RectangleF]::new($x, $y - ($size * 0.08), $size, $size)
    $graphics.DrawString($text, $font, $textBrush, $rect, $format)
    $graphics.DrawLine($linePen, $x + ($size * 0.24), $y + ($size * 0.72), $x + ($size * 0.76), $y + ($size * 0.72))

    $format.Dispose()
    $font.Dispose()
    $textBrush.Dispose()
    $linePen.Dispose()
    $fillBrush.Dispose()
}

function New-LarderLabelsIcon($path, $size) {
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#276B63"))

    $scale = $size / 192.0
    $surfaceBrush = New-Brush "#F1F7F4"
    $shadowBrush = New-Brush "#16443F"
    $accentBrush = New-Brush "#F0B429"

    Add-RoundedRectangle $graphics $shadowBrush (20 * $scale) (26 * $scale) (152 * $scale) (146 * $scale) (28 * $scale)
    Add-RoundedRectangle $graphics $surfaceBrush (16 * $scale) (18 * $scale) (152 * $scale) (146 * $scale) (28 * $scale)

    $tile = 48 * $scale
    Add-LabelTile $graphics (38 * $scale) (38 * $scale) $tile "#E9F6EE" "JAR"
    Add-LabelTile $graphics (106 * $scale) (38 * $scale) $tile "#E2F7F2" "TEA"
    Add-LabelTile $graphics (38 * $scale) (106 * $scale) $tile "#FFF5D8" "OAT"
    Add-LabelTile $graphics (106 * $scale) (106 * $scale) $tile "#FFE9E5" "TIN"

    Add-RoundedRectangle $graphics $accentBrush (78 * $scale) (78 * $scale) (36 * $scale) (36 * $scale) (10 * $scale)

    $directory = Split-Path -Parent $path
    if (!(Test-Path $directory)) {
        New-Item -ItemType Directory -Force $directory | Out-Null
    }
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $accentBrush.Dispose()
    $surfaceBrush.Dispose()
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
    New-LarderLabelsIcon (Join-Path $Root $entry.Key) $entry.Value
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
    New-LarderLabelsIcon (Join-Path $Root $entry.Key) $entry.Value
}

$webIcons = @{
    "web/favicon.png" = 32
    "web/icons/Icon-192.png" = 192
    "web/icons/Icon-512.png" = 512
    "web/icons/Icon-maskable-192.png" = 192
    "web/icons/Icon-maskable-512.png" = 512
}

foreach ($entry in $webIcons.GetEnumerator()) {
    New-LarderLabelsIcon (Join-Path $Root $entry.Key) $entry.Value
}

Write-Host "Generated Larder Labels launcher icons."
