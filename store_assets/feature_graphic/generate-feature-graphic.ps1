Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 500
$outPath = Join-Path $PSScriptRoot "dots-and-boxes-feature-graphic.png"

function ColorFromHex {
    param([string] $Hex)
    $clean = $Hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($clean.Substring(0, 2), 16),
        [Convert]::ToInt32($clean.Substring(2, 2), 16),
        [Convert]::ToInt32($clean.Substring(4, 2), 16)
    )
}

function Brush {
    param([string] $Hex)
    return New-Object System.Drawing.SolidBrush (ColorFromHex $Hex)
}

function AlphaBrush {
    param([int] $Alpha, [string] $Hex)
    $base = ColorFromHex $Hex
    return New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($Alpha, $base))
}

function Pen {
    param([string] $Hex, [float] $Width)
    $pen = New-Object System.Drawing.Pen (ColorFromHex $Hex), $Width
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    return $pen
}

function AlphaPen {
    param([int] $Alpha, [string] $Hex, [float] $Width)
    $base = ColorFromHex $Hex
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($Alpha, $base)), $Width
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    return $pen
}

function RoundedPath {
    param([float] $X, [float] $Y, [float] $W, [float] $H, [float] $R)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $R * 2
    $path.AddArc($X, $Y, $d, $d, 180, 90)
    $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function FillRoundedRect {
    param($Graphics, [float] $X, [float] $Y, [float] $W, [float] $H, [float] $R, $Brush)
    $path = RoundedPath $X $Y $W $H $R
    $Graphics.FillPath($Brush, $path)
    $path.Dispose()
}

function DrawRoundedRect {
    param($Graphics, [float] $X, [float] $Y, [float] $W, [float] $H, [float] $R, $Pen)
    $path = RoundedPath $X $Y $W $H $R
    $Graphics.DrawPath($Pen, $path)
    $path.Dispose()
}

function DrawCenteredText {
    param($Graphics, [string] $Text, $Font, $Brush, [float] $CenterX, [float] $CenterY)
    $size = $Graphics.MeasureString($Text, $Font)
    $Graphics.DrawString($Text, $Font, $Brush, $CenterX - ($size.Width / 2), $CenterY - ($size.Height / 2))
}

$bitmap = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$graphics.Clear((ColorFromHex "#F8FAFC"))

$bgBrush = Brush "#F8FAFC"
$darkBrush = Brush "#0F172A"
$mutedBrush = Brush "#475569"
$blueBrush = Brush "#2563EB"
$redBrush = Brush "#DC2626"
$whiteBrush = Brush "#FFFFFF"
$guidePen = Pen "#CBD5E1" 4
$bluePen = Pen "#2563EB" 18
$redPen = Pen "#DC2626" 18
$darkPen = Pen "#0F172A" 3
$panelPen = Pen "#CBD5E1" 2
$shadowBrush = AlphaBrush 24 "#0F172A"
$blueFillBrush = AlphaBrush 46 "#2563EB"
$redFillBrush = AlphaBrush 40 "#DC2626"
$blueSoftBrush = AlphaBrush 22 "#2563EB"
$redSoftBrush = AlphaBrush 18 "#DC2626"

try {
    # Quiet brand field that keeps the left side useful on all Play placements.
    FillRoundedRect $graphics 52 48 390 404 28 (AlphaBrush 245 "#FFFFFF")
    DrawRoundedRect $graphics 52 48 390 404 28 (AlphaPen 110 "#CBD5E1" 2)
    FillRoundedRect $graphics 82 88 112 36 18 $blueSoftBrush
    FillRoundedRect $graphics 204 88 92 36 18 $redSoftBrush

    $titleFont = New-Object System.Drawing.Font "Segoe UI", 50, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $subFont = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $smallFont = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)

    $graphics.DrawString("Dots", $titleFont, $darkBrush, 82, 145)
    $graphics.DrawString("and Boxes", $titleFont, $darkBrush, 82, 202)
    $graphics.DrawString("Draw lines. Close boxes.", $subFont, $mutedBrush, 86, 286)
    $graphics.DrawString("Keep scoring turns.", $subFont, $mutedBrush, 86, 322)

    # Board stage.
    FillRoundedRect $graphics 486 60 466 380 30 $shadowBrush
    FillRoundedRect $graphics 470 44 466 380 30 $whiteBrush
    DrawRoundedRect $graphics 470 44 466 380 30 $panelPen

    $originX = 545
    $originY = 102
    $cell = 70
    $rows = 5
    $cols = 5

    # Captured boxes first, exactly like the game paints ownership underneath lines.
    FillRoundedRect $graphics ($originX + $cell + 9) ($originY + $cell + 9) ($cell - 18) ($cell - 18) 9 $blueFillBrush
    FillRoundedRect $graphics ($originX + (2 * $cell) + 9) ($originY + $cell + 9) ($cell - 18) ($cell - 18) 9 $redFillBrush
    FillRoundedRect $graphics ($originX + (2 * $cell) + 9) ($originY + (2 * $cell) + 9) ($cell - 18) ($cell - 18) 9 $blueFillBrush

    # Pale guide grid.
    for ($r = 0; $r -lt $rows; $r += 1) {
        for ($c = 0; $c -lt ($cols - 1); $c += 1) {
            $x1 = $originX + ($c * $cell)
            $y1 = $originY + ($r * $cell)
            $x2 = $originX + (($c + 1) * $cell)
            $graphics.DrawLine($guidePen, $x1, $y1, $x2, $y1)
        }
    }
    for ($r = 0; $r -lt ($rows - 1); $r += 1) {
        for ($c = 0; $c -lt $cols; $c += 1) {
            $x1 = $originX + ($c * $cell)
            $y1 = $originY + ($r * $cell)
            $y2 = $originY + (($r + 1) * $cell)
            $graphics.DrawLine($guidePen, $x1, $y1, $x1, $y2)
        }
    }

    # Honest gameplay-like move state with blue and red line ownership.
    $lines = @(
        @("B", 1, 1, 2, 1), @("B", 1, 1, 1, 2), @("B", 1, 2, 2, 2),
        @("B", 2, 1, 2, 2), @("B", 2, 2, 3, 2), @("B", 3, 2, 3, 3),
        @("R", 2, 1, 3, 1), @("R", 3, 1, 3, 2), @("R", 2, 2, 2, 3),
        @("R", 3, 2, 4, 2), @("R", 4, 1, 4, 2), @("R", 1, 3, 2, 3),
        @("B", 0, 0, 1, 0), @("B", 0, 0, 0, 1), @("R", 3, 3, 4, 3)
    )

    foreach ($line in $lines) {
        $pen = if ($line[0] -eq "B") { $bluePen } else { $redPen }
        $x1 = $originX + ([int]$line[1] * $cell)
        $y1 = $originY + ([int]$line[2] * $cell)
        $x2 = $originX + ([int]$line[3] * $cell)
        $y2 = $originY + ([int]$line[4] * $cell)
        $graphics.DrawLine($pen, $x1, $y1, $x2, $y2)
    }

    # One emphasized capture to communicate the core scoring moment.
    DrawRoundedRect $graphics ($originX + (2 * $cell) + 5) ($originY + (2 * $cell) + 5) ($cell - 10) ($cell - 10) 10 (AlphaPen 150 "#2563EB" 5)
    DrawCenteredText $graphics "1" $smallFont $blueBrush ($originX + (2.5 * $cell)) ($originY + (2.5 * $cell))
    DrawCenteredText $graphics "2" $smallFont $redBrush ($originX + (2.5 * $cell)) ($originY + (1.5 * $cell))

    # Dots are intentionally bold so the asset still reads at small Play surfaces.
    for ($r = 0; $r -lt $rows; $r += 1) {
        for ($c = 0; $c -lt $cols; $c += 1) {
            $x = $originX + ($c * $cell)
            $y = $originY + ($r * $cell)
            $graphics.FillEllipse($darkBrush, $x - 8, $y - 8, 16, 16)
        }
    }

    # Small score chips, kept large enough to read and truthful to local play.
    FillRoundedRect $graphics 510 356 150 42 21 (AlphaBrush 22 "#2563EB")
    FillRoundedRect $graphics 690 356 150 42 21 (AlphaBrush 20 "#DC2626")
    $graphics.DrawString("Player 1", $smallFont, $blueBrush, 530, 362)
    $graphics.DrawString("Player 2", $smallFont, $redBrush, 710, 362)

    $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
    $bgBrush.Dispose()
    $darkBrush.Dispose()
    $mutedBrush.Dispose()
    $blueBrush.Dispose()
    $redBrush.Dispose()
    $whiteBrush.Dispose()
    $guidePen.Dispose()
    $bluePen.Dispose()
    $redPen.Dispose()
    $darkPen.Dispose()
    $panelPen.Dispose()
    $shadowBrush.Dispose()
    $blueFillBrush.Dispose()
    $redFillBrush.Dispose()
    $blueSoftBrush.Dispose()
    $redSoftBrush.Dispose()
}

Write-Host "Created $outPath"
