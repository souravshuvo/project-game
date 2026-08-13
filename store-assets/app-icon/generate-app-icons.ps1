$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..\..')
$boardSpecPath = Join-Path $repoRoot 'lib\src\game\domain\board_spec.dart'

if (-not (Test-Path $boardSpecPath)) {
  throw "Board specification not found at $boardSpecPath"
}

$outDir = $scriptDir
$sourcePath = Join-Path $outDir 'sixteen-breed-launcher-icon-source-1024.png'
$playPath = Join-Path $outDir 'sixteen-breed-play-icon-512.png'

function Color-Hex([string]$hex) {
  $value = $hex.TrimStart('#')
  return [System.Drawing.Color]::FromArgb(
    255,
    [Convert]::ToInt32($value.Substring(0, 2), 16),
    [Convert]::ToInt32($value.Substring(2, 2), 16),
    [Convert]::ToInt32($value.Substring(4, 2), 16)
  )
}

function Color-Argb([int]$alpha, [string]$hex) {
  $base = Color-Hex $hex
  return [System.Drawing.Color]::FromArgb($alpha, $base.R, $base.G, $base.B)
}

function New-RoundedRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Read-BoardSpec {
  $content = Get-Content $boardSpecPath -Raw
  $nodes = @{}
  $edges = New-Object System.Collections.Generic.List[object]

  [regex]::Matches($content, 'BoardNode\((\d+),\s*([0-9.]+),\s*([0-9.]+)\)') |
    ForEach-Object {
      $id = [int]$_.Groups[1].Value
      $nodes[$id] = @([double]$_.Groups[2].Value, [double]$_.Groups[3].Value)
    }

  [regex]::Matches($content, 'BoardEdge\((\d+),\s*(\d+)\)') |
    ForEach-Object {
      $edges.Add(@([int]$_.Groups[1].Value, [int]$_.Groups[2].Value))
    }

  if ($nodes.Count -ne 37) {
    throw "Expected 37 board nodes, found $($nodes.Count)."
  }

  if ($edges.Count -lt 1) {
    throw 'No board edges were parsed.'
  }

  return @{
    Nodes = $nodes
    Edges = $edges
  }
}

function Get-NodePoint($nodes, [int]$id, [System.Drawing.RectangleF]$rect) {
  if (-not $nodes.ContainsKey($id)) {
    throw "Icon bead node $id is missing from the board specification."
  }

  $node = $nodes[$id]
  $x = $rect.Left + ([double]$node[0] * $rect.Width)
  $y = $rect.Top + ([double]$node[1] * $rect.Height)
  return [System.Drawing.PointF]::new([float]$x, [float]$y)
}

function Draw-Bead(
  [System.Drawing.Graphics]$g,
  [System.Drawing.PointF]$center,
  [float]$radius,
  [string]$baseHex,
  [string]$highlightHex,
  [string]$outlineHex
) {
  $shadow = [System.Drawing.RectangleF]::new(
    $center.X - $radius + ($radius * 0.12),
    $center.Y - $radius + ($radius * 0.18),
    $radius * 2,
    $radius * 2
  )
  $shadowBrush = [System.Drawing.SolidBrush]::new((Color-Argb 85 '#1A130F'))
  $g.FillEllipse($shadowBrush, $shadow)
  $shadowBrush.Dispose()

  $rect = [System.Drawing.RectangleF]::new(
    $center.X - $radius,
    $center.Y - $radius,
    $radius * 2,
    $radius * 2
  )
  $beadBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rect,
    (Color-Hex $highlightHex),
    (Color-Hex $baseHex),
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
  )
  $g.FillEllipse($beadBrush, $rect)
  $beadBrush.Dispose()

  $outlinePen = [System.Drawing.Pen]::new((Color-Hex $outlineHex), [Math]::Max(2, $radius * 0.12))
  $g.DrawEllipse($outlinePen, $rect)
  $outlinePen.Dispose()

  $shineRect = [System.Drawing.RectangleF]::new(
    $center.X - ($radius * 0.48),
    $center.Y - ($radius * 0.56),
    $radius * 0.68,
    $radius * 0.44
  )
  $shineBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 255, 255, 255))
  $g.FillEllipse($shineBrush, $shineRect)
  $shineBrush.Dispose()
}

function Draw-Icon([int]$size, [string]$path) {
  $spec = Read-BoardSpec
  $nodes = $spec.Nodes
  $edges = $spec.Edges

  $bitmap = [System.Drawing.Bitmap]::new(
    $size,
    $size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )

  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

  $canvas = [System.Drawing.RectangleF]::new(0, 0, $size, $size)
  $backgroundBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $canvas,
    (Color-Hex '#3E7773'),
    (Color-Hex '#244946'),
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
  )
  $g.FillRectangle($backgroundBrush, $canvas)
  $backgroundBrush.Dispose()

  $shadowPath = New-RoundedRectPath ($size * 0.125) ($size * 0.145) ($size * 0.75) ($size * 0.75) ($size * 0.09)
  $shadowMatrix = [System.Drawing.Drawing2D.Matrix]::new()
  $shadowMatrix.Translate($size * 0.018, $size * 0.026)
  $shadowPath.Transform($shadowMatrix)
  $shadowBrush = [System.Drawing.SolidBrush]::new((Color-Argb 75 '#111111'))
  $g.FillPath($shadowBrush, $shadowPath)
  $shadowBrush.Dispose()
  $shadowPath.Dispose()
  $shadowMatrix.Dispose()

  $boardPath = New-RoundedRectPath ($size * 0.125) ($size * 0.125) ($size * 0.75) ($size * 0.75) ($size * 0.09)
  $boardRect = [System.Drawing.RectangleF]::new($size * 0.125, $size * 0.125, $size * 0.75, $size * 0.75)
  $boardBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $boardRect,
    (Color-Hex '#F8EBCF'),
    (Color-Hex '#E4C38C'),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
  )
  $g.FillPath($boardBrush, $boardPath)
  $boardBrush.Dispose()

  $borderPen = [System.Drawing.Pen]::new((Color-Hex '#5F4631'), [Math]::Max(4, $size * 0.018))
  $g.DrawPath($borderPen, $boardPath)
  $borderPen.Dispose()

  $inner = [System.Drawing.RectangleF]::new(
    $size * 0.225,
    $size * 0.185,
    $size * 0.55,
    $size * 0.63
  )

  $captureFrom = Get-NodePoint $nodes 12 $inner
  $captureOver = Get-NodePoint $nodes 18 $inner
  $captureTo = Get-NodePoint $nodes 24 $inner

  $capturePen = [System.Drawing.Pen]::new((Color-Argb 160 '#C77800'), [Math]::Max(8, $size * 0.034))
  $capturePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $capturePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($capturePen, $captureFrom, $captureTo)
  $capturePen.Dispose()

  $linePen = [System.Drawing.Pen]::new((Color-Argb 225 '#3E2A1E'), [Math]::Max(3, $size * 0.012))
  $linePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $linePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  foreach ($edge in $edges) {
    $a = Get-NodePoint $nodes $edge[0] $inner
    $b = Get-NodePoint $nodes $edge[1] $inner
    $g.DrawLine($linePen, $a, $b)
  }
  $linePen.Dispose()

  $dotBrush = [System.Drawing.SolidBrush]::new((Color-Argb 170 '#3E2A1E'))
  $dotRadius = [Math]::Max(2.5, $size * 0.008)
  foreach ($id in $nodes.Keys) {
    $point = Get-NodePoint $nodes $id $inner
    $g.FillEllipse(
      $dotBrush,
      [System.Drawing.RectangleF]::new($point.X - $dotRadius, $point.Y - $dotRadius, $dotRadius * 2, $dotRadius * 2)
    )
  }
  $dotBrush.Dispose()

  $ringPen = [System.Drawing.Pen]::new((Color-Hex '#C77800'), [Math]::Max(5, $size * 0.016))
  $targetRadius = $size * 0.048
  $g.DrawEllipse(
    $ringPen,
    [System.Drawing.RectangleF]::new(
      $captureTo.X - $targetRadius,
      $captureTo.Y - $targetRadius,
      $targetRadius * 2,
      $targetRadius * 2
    )
  )
  $ringPen.Dispose()

  $beadRadius = $size * 0.068
  Draw-Bead $g $captureFrom $beadRadius '#B74135' '#E46E61' '#6F211A'
  Draw-Bead $g $captureOver $beadRadius '#265C9E' '#5B8FD0' '#102F5C'

  $smallBeadRadius = $size * 0.047
  Draw-Bead $g (Get-NodePoint $nodes 13 $inner) $smallBeadRadius '#B74135' '#E46E61' '#6F211A'
  Draw-Bead $g (Get-NodePoint $nodes 23 $inner) $smallBeadRadius '#265C9E' '#5B8FD0' '#102F5C'

  $boardPath.Dispose()
  $g.Dispose()

  $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

function Resize-Png([string]$source, [string]$dest, [int]$size) {
  $src = [System.Drawing.Image]::FromFile($source)
  $bitmap = [System.Drawing.Bitmap]::new(
    $size,
    $size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )

  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($src, [System.Drawing.Rectangle]::new(0, 0, $size, $size))
  $g.Dispose()
  $src.Dispose()

  $bitmap.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

Draw-Icon 1024 $sourcePath
Resize-Png $sourcePath $playPath 512

Write-Output "Created $sourcePath"
Write-Output "Created $playPath"
