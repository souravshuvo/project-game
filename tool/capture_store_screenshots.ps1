param(
    [string] $DeviceId = "",
    [string] $Package = "com.childhood.larderlabels",
    [string] $OutputDirectory = "store_assets/screenshots/phone",
    [int] $StartupDelaySeconds = 8
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$OutputPath = Join-Path $Root $OutputDirectory
$Adb = Join-Path $env:LOCALAPPDATA "Android/sdk/platform-tools/adb.exe"

if (!(Test-Path $Adb)) {
    $Adb = "adb"
}

if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Force $OutputPath | Out-Null
}

function Invoke-Adb {
    param([string[]] $Arguments)

    $baseArgs = @()
    if ($DeviceId -ne "") {
        $baseArgs += @("-s", $DeviceId)
    }

    & $Adb @baseArgs @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "adb command failed: $($Arguments -join ' ')"
    }
}

function Get-ScreenSize {
    $sizeOutput = Invoke-Adb @("shell", "wm", "size")
    if ($sizeOutput -match "Physical size:\s*(\d+)x(\d+)") {
        return @{
            Width = [int] $Matches[1]
            Height = [int] $Matches[2]
        }
    }

    throw "Could not read device screen size."
}

function Tap-Ratio {
    param([double] $XRatio, [double] $YRatio)

    $x = [Math]::Round($script:Screen.Width * $XRatio)
    $y = [Math]::Round($script:Screen.Height * $YRatio)
    Invoke-Adb @("shell", "input", "tap", "$x", "$y") | Out-Null
}

function Save-Screenshot {
    param([string] $Name)

    $devicePath = "/sdcard/$Name.png"
    $localPath = Join-Path $OutputPath "$Name.png"
    Invoke-Adb @("shell", "screencap", "-p", $devicePath) | Out-Null
    Invoke-Adb @("pull", $devicePath, $localPath) | Out-Null
    Invoke-Adb @("shell", "rm", $devicePath) | Out-Null
    Write-Host "Saved $localPath"
}

$script:Screen = Get-ScreenSize

Invoke-Adb @("shell", "am", "force-stop", $Package) | Out-Null
Invoke-Adb @("shell", "pm", "clear", $Package) | Out-Null
Invoke-Adb @("shell", "am", "start", "-n", "$Package/.MainActivity") | Out-Null
Start-Sleep -Seconds $StartupDelaySeconds
Save-Screenshot "01-gameplay-start"

# Level 1 is a flat 6 x 3 board. These taps target the first column on common
# portrait phones and should be reviewed after capture.
Tap-Ratio 0.15 0.38
Start-Sleep -Milliseconds 500
Tap-Ratio 0.15 0.50
Start-Sleep -Milliseconds 500
Tap-Ratio 0.15 0.62
Start-Sleep -Seconds 1
Save-Screenshot "02-triple-cleared"

Tap-Ratio 0.32 0.38
Start-Sleep -Milliseconds 500
Tap-Ratio 0.48 0.38
Start-Sleep -Milliseconds 500
Save-Screenshot "03-tray-in-progress"

Write-Host "Captured Larder Labels screenshots for $Package in $OutputPath"
