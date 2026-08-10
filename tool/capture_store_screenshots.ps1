param(
    [string] $DeviceId = "",
    [string] $Package = "com.childhood.pocketobservatory",
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
Save-Screenshot "01-setup"

Tap-Ratio 0.50 0.52
Start-Sleep -Seconds 2
Save-Screenshot "02-active-round"

Tap-Ratio 0.28 0.42
Start-Sleep -Milliseconds 500
Tap-Ratio 0.28 0.55
Start-Sleep -Milliseconds 500
Tap-Ratio 0.50 0.42
Start-Sleep -Milliseconds 500
Tap-Ratio 0.50 0.55
Start-Sleep -Milliseconds 500
Tap-Ratio 0.72 0.42
Start-Sleep -Seconds 1
Save-Screenshot "03-win-result"

Tap-Ratio 0.94 0.06
Start-Sleep -Milliseconds 700
Save-Screenshot "04-settings"

Write-Host "Captured screenshots for $Package in $OutputPath"
