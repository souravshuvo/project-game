Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$ErrorActionPreference = 'Stop'

$width = 1024
$height = 500
$outPath = Join-Path $PSScriptRoot 'sixteen-breed-feature-graphic.png'

$bitmap = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

function ColorFromHex([string] $hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Brush([string] $hex) {
    return New-Object System.Drawing.SolidBrush (ColorFromHex $hex)
}

function Pen([string] $hex, [float] $size) {
    $pen = New-Object System.Drawing.Pen (ColorFromHex $hex), $size
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    return $pen
}

function DrawRoundRect($g, $brush, $pen, [float] $x, [float] $y, [float] $w, [float] $h, [float] $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($brush -ne $null) { $g.FillPath($brush, $path) }
    if ($pen -ne $null) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function DrawBead($g, [float] $x, [float] $y, [float] $r, [string] $fill) {
    $shadow = Brush '#000000'
    $shadow.Color = [System.Drawing.Color]::FromArgb(70, $shadow.Color)
    $g.FillEllipse($shadow, $x - $r + 3, $y - $r + 4, $r * 2, $r * 2)
    $shadow.Dispose()

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse($x - $r, $y - $r, $r * 2, $r * 2)
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
    $brush.CenterColor = [System.Drawing.Color]::White
    $brush.SurroundColors = @((ColorFromHex $fill))
    $brush.CenterPoint = New-Object System.Drawing.PointF ($x - $r * 0.35), ($y - $r * 0.35)
    $g.FillEllipse($brush, $x - $r, $y - $r, $r * 2, $r * 2)

    $rim = Pen '#FFFFFF' 1.8
    $rim.Color = [System.Drawing.Color]::FromArgb(105, $rim.Color)
    $g.DrawEllipse($rim, $x - $r + 1, $y - $r + 1, ($r - 1) * 2, ($r - 1) * 2)

    $brush.Dispose()
    $path.Dispose()
    $rim.Dispose()
}

$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
    (New-Object System.Drawing.Rectangle 0, 0, $width, $height),
    (ColorFromHex '#386A67'),
    (ColorFromHex '#183B3A'),
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$graphics.FillRectangle($bg, 0, 0, $width, $height)
$bg.Dispose()

$glow = Brush '#F5E6C8'
$glow.Color = [System.Drawing.Color]::FromArgb(22, $glow.Color)
$graphics.FillEllipse($glow, 568, -160, 590, 590)
$graphics.FillEllipse($glow, -120, 220, 420, 420)
$glow.Dispose()

$boardX = 58
$boardY = 36
$boardW = 430
$boardH = 430
$boardBrush = Brush '#F5E6C8'
$boardPen = Pen '#5F4631' 4
DrawRoundRect $graphics $boardBrush $boardPen $boardX $boardY $boardW $boardH 18
$boardBrush.Dispose()
$boardPen.Dispose()

$nodes = @{
    0=@(0.25,0.0); 1=@(0.5,0.0); 2=@(0.75,0.0); 3=@(0.375,0.125); 4=@(0.5,0.125); 5=@(0.625,0.125);
    6=@(0.0,0.25); 7=@(0.25,0.25); 8=@(0.5,0.25); 9=@(0.75,0.25); 10=@(1.0,0.25);
    11=@(0.0,0.375); 12=@(0.25,0.375); 13=@(0.5,0.375); 14=@(0.75,0.375); 15=@(1.0,0.375);
    16=@(0.0,0.5); 17=@(0.25,0.5); 18=@(0.5,0.5); 19=@(0.75,0.5); 20=@(1.0,0.5);
    21=@(0.0,0.625); 22=@(0.25,0.625); 23=@(0.5,0.625); 24=@(0.75,0.625); 25=@(1.0,0.625);
    26=@(0.0,0.75); 27=@(0.25,0.75); 28=@(0.5,0.75); 29=@(0.75,0.75); 30=@(1.0,0.75);
    31=@(0.375,0.875); 32=@(0.5,0.875); 33=@(0.625,0.875); 34=@(0.25,1.0); 35=@(0.5,1.0); 36=@(0.75,1.0)
}

$edges = @(
    @(0,1),@(0,3),@(1,2),@(1,4),@(2,5),@(3,4),@(3,8),@(4,5),@(4,8),@(5,8),
    @(6,7),@(6,11),@(6,12),@(7,8),@(7,12),@(8,9),@(8,12),@(8,13),@(8,14),@(9,10),@(9,14),@(10,14),@(10,15),
    @(11,12),@(11,16),@(12,13),@(12,16),@(12,17),@(12,18),@(13,14),@(13,18),@(14,15),@(14,18),@(14,19),@(14,20),@(15,20),
    @(16,17),@(16,21),@(16,22),@(17,18),@(17,22),@(18,19),@(18,22),@(18,23),@(18,24),@(19,20),@(19,24),@(20,24),@(20,25),
    @(21,22),@(21,26),@(22,23),@(22,26),@(22,27),@(22,28),@(23,24),@(23,28),@(24,25),@(24,28),@(24,29),@(24,30),@(25,30),
    @(26,27),@(27,28),@(28,29),@(28,31),@(28,32),@(28,33),@(29,30),@(31,32),@(31,34),@(32,33),@(32,35),@(33,36),@(34,35),@(35,36)
)

function Pos([int] $id) {
    $padding = 28
    $coord = @($script:nodes[[int]$id])
    $xRatio = [double]$coord[0]
    $yRatio = [double]$coord[1]
    $x = [double]$script:boardX + $padding + ($xRatio * ([double]$script:boardW - $padding * 2))
    $y = [double]$script:boardY + $padding + ($yRatio * ([double]$script:boardH - $padding * 2))
    return @($x, $y)
}

$edgePen = Pen '#3E2A1E' 2.8
foreach ($edge in $edges) {
    $a = Pos $edge[0]
    $b = Pos $edge[1]
    $graphics.DrawLine($edgePen, [float]$a[0], [float]$a[1], [float]$b[0], [float]$b[1])
}
$edgePen.Dispose()

$capturePen = Pen '#C77800' 10
$capturePen.Color = [System.Drawing.Color]::FromArgb(190, $capturePen.Color)
$from = Pos 11
$over = Pos 16
$to = Pos 21
$graphics.DrawLine($capturePen, [float]$from[0], [float]$from[1], [float]$to[0], [float]$to[1])
$capturePen.Dispose()

$amberPen = Pen '#C77800' 4
$graphics.DrawEllipse($amberPen, $over[0] - 22, $over[1] - 22, 44, 44)
$graphics.DrawEllipse($amberPen, $to[0] - 24, $to[1] - 24, 48, 48)
$amberPen.Dispose()

$dotBrush = Brush '#3E2A1E'
foreach ($id in $nodes.Keys) {
    $p = Pos $id
    $graphics.FillEllipse($dotBrush, $p[0] - 3, $p[1] - 3, 6, 6)
}
$dotBrush.Dispose()

$player1 = @(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
$player2 = @(16,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)

foreach ($id in $player2) {
    $p = Pos $id
    DrawBead $graphics $p[0] $p[1] 13 '#265C9E'
}
foreach ($id in $player1) {
    $p = Pos $id
    DrawBead $graphics $p[0] $p[1] 13 '#B74135'
}

$titleBrush = Brush '#FFFFFF'
$subBrush = Brush '#F5E6C8'
$accentBrush = Brush '#C77800'
$titleFont = New-Object System.Drawing.Font 'Segoe UI', 60, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$subFont = New-Object System.Drawing.Font 'Segoe UI', 28, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$labelFont = New-Object System.Drawing.Font 'Segoe UI', 19, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)

$graphics.DrawString('Sixteen', $titleFont, $titleBrush, 555, 120)
$graphics.DrawString('Breed', $titleFont, $titleBrush, 555, 186)
$graphics.FillRectangle($accentBrush, 558, 270, 170, 6)
$graphics.DrawString('Sholo Guti / 16 Beads', $subFont, $subBrush, 555, 292)
$graphics.DrawString('Offline board strategy', $labelFont, $subBrush, 558, 340)

$titleBrush.Dispose()
$subBrush.Dispose()
$accentBrush.Dispose()
$titleFont.Dispose()
$subFont.Dispose()
$labelFont.Dispose()

$bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()
