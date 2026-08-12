Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path $PSScriptRoot "dots-and-boxes-launcher-source-1024.png"
$playStorePath = Join-Path $PSScriptRoot "dots-and-boxes-play-store-icon-512.png"

function ColorFromHex([string]$hex) {
    $value = $hex.TrimStart("#")
    $r = [Convert]::ToInt32($value.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($value.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($value.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb(255, $r, $g, $b)
}

function ColorFromHexAlpha([string]$hex, [int]$alpha) {
    $value = $hex.TrimStart("#")
    $r = [Convert]::ToInt32($value.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($value.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($value.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
}

function New-SolidBrush([System.Drawing.Color]$color) {
    return [System.Drawing.SolidBrush]::new($color)
}

function New-Pen([System.Drawing.Color]$color, [float]$width) {
    $pen = [System.Drawing.Pen]::new($color, $width)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    return $pen
}

function New-RoundedRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$radius) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-RoundedRectangle(
    [System.Drawing.Graphics]$graphics,
    [float]$x,
    [float]$y,
    [float]$w,
    [float]$h,
    [float]$radius,
    [System.Drawing.Brush]$brush,
    [System.Drawing.Pen]$pen
) {
    $path = New-RoundedRectPath $x $y $w $h $radius
    try {
        if ($null -ne $brush) {
            $graphics.FillPath($brush, $path)
        }
        if ($null -ne $pen) {
            $graphics.DrawPath($pen, $path)
        }
    }
    finally {
        $path.Dispose()
    }
}

function Draw-Line(
    [System.Drawing.Graphics]$graphics,
    [float]$x1,
    [float]$y1,
    [float]$x2,
    [float]$y2,
    [System.Drawing.Color]$color,
    [float]$width
) {
    $pen = New-Pen $color $width
    try {
        $graphics.DrawLine($pen, $x1, $y1, $x2, $y2)
    }
    finally {
        $pen.Dispose()
    }
}

function Draw-Dot(
    [System.Drawing.Graphics]$graphics,
    [float]$x,
    [float]$y,
    [float]$radius,
    [System.Drawing.Color]$color
) {
    $brush = New-SolidBrush $color
    try {
        $graphics.FillEllipse($brush, $x - $radius, $y - $radius, $radius * 2, $radius * 2)
    }
    finally {
        $brush.Dispose()
    }
}

function New-IconBitmap([int]$size) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $blue = ColorFromHex "#2563EB"
    $red = ColorFromHex "#DC2626"
    $dot = ColorFromHex "#0F172A"
    $guide = ColorFromHex "#CBD5E1"
    $tile = ColorFromHex "#F8FAFC"
    $border = ColorFromHex "#E2E8F0"

    $tileBrush = New-SolidBrush $tile
    $borderPen = [System.Drawing.Pen]::new($border, 12)
    try {
        Draw-RoundedRectangle $graphics 80 80 864 864 180 $tileBrush $borderPen
    }
    finally {
        $tileBrush.Dispose()
        $borderPen.Dispose()
    }

    $blueFill = New-SolidBrush (ColorFromHexAlpha "#2563EB" 34)
    $redFill = New-SolidBrush (ColorFromHexAlpha "#DC2626" 30)
    try {
        Draw-RoundedRectangle $graphics 288 288 224 224 42 $blueFill $null
        Draw-RoundedRectangle $graphics 512 512 224 224 42 $redFill $null
    }
    finally {
        $blueFill.Dispose()
        $redFill.Dispose()
    }

    $xs = @(288, 512, 736)
    $ys = @(288, 512, 736)

    foreach ($y in $ys) {
        Draw-Line $graphics $xs[0] $y $xs[2] $y $guide 34
    }
    foreach ($x in $xs) {
        Draw-Line $graphics $x $ys[0] $x $ys[2] $guide 34
    }

    Draw-Line $graphics 288 288 512 288 $blue 72
    Draw-Line $graphics 288 288 288 512 $blue 72
    Draw-Line $graphics 288 512 512 512 $blue 72
    Draw-Line $graphics 512 288 512 512 $blue 72

    Draw-Line $graphics 512 512 736 512 $red 72
    Draw-Line $graphics 736 512 736 736 $red 72
    Draw-Line $graphics 512 736 736 736 $red 72

    foreach ($x in $xs) {
        foreach ($y in $ys) {
            Draw-Dot $graphics $x $y 38 $dot
        }
    }

    $graphics.Dispose()
    return $bitmap
}

function Save-Png([System.Drawing.Bitmap]$bitmap, [string]$path) {
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Resize-Bitmap([System.Drawing.Bitmap]$source, [int]$size) {
    $target = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($target)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.DrawImage($source, 0, 0, $size, $size)
    }
    finally {
        $graphics.Dispose()
    }
    return $target
}

New-Item -ItemType Directory -Force -Path $PSScriptRoot | Out-Null

$source = New-IconBitmap 1024
try {
    Save-Png $source $sourcePath
    $playStore = Resize-Bitmap $source 512
    try {
        Save-Png $playStore $playStorePath
    }
    finally {
        $playStore.Dispose()
    }
}
finally {
    $source.Dispose()
}

Write-Output "Created $sourcePath"
Write-Output "Created $playStorePath"
