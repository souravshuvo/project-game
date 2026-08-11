[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$GradleJvm = "jbr-21"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[repair] $Message"
}

function Fail {
    param([string]$Message)
    throw "[Android Studio repair] $Message"
}

function Escape-Xml {
    param([string]$Value)
    if ($null -eq $Value) {
        return ""
    }
    return [System.Security.SecurityElement]::Escape($Value)
}

function To-IdeaFileUrl {
    param([string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path).Replace("\", "/")
    return "file://$fullPath"
}

function Save-Utf8 {
    param(
        [string]$Path,
        [string]$Content
    )

    $directory = Split-Path -Parent $Path
    if ($directory) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function Read-LocalProperty {
    param(
        [string]$Path,
        [string]$Key
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    foreach ($line in Get-Content $Path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        $equalsIndex = $trimmed.IndexOf("=")
        if ($equalsIndex -le 0) {
            continue
        }

        $name = $trimmed.Substring(0, $equalsIndex).Trim()
        if ($name -eq $Key) {
            return $trimmed.Substring($equalsIndex + 1).Trim() -replace "\\\\", "\"
        }
    }

    return $null
}

function Find-FlutterSdk {
    param([string]$Root)

    $localProperties = Join-Path $Root "android\local.properties"
    $configuredSdk = Read-LocalProperty -Path $localProperties -Key "flutter.sdk"
    if ($configuredSdk -and (Test-Path (Join-Path $configuredSdk "bin\cache\dart-sdk"))) {
        return [System.IO.Path]::GetFullPath($configuredSdk)
    }

    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCommand) {
        $flutterBin = Split-Path -Parent $flutterCommand.Source
        $flutterRoot = Split-Path -Parent $flutterBin
        if (Test-Path (Join-Path $flutterRoot "bin\cache\dart-sdk")) {
            return [System.IO.Path]::GetFullPath($flutterRoot)
        }
    }

    return $null
}

function Resolve-PackageConfigPath {
    param(
        [string]$BaseDirectory,
        [string]$UriText
    )

    if ([string]::IsNullOrWhiteSpace($UriText)) {
        return $null
    }

    if ($UriText -match "^[a-zA-Z][a-zA-Z0-9+\-.]*:") {
        $uri = [System.Uri]$UriText
        if ($uri.IsFile) {
            return $uri.LocalPath
        }

        return $null
    }

    $relativePath = $UriText.Replace("/", "\")
    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $relativePath))
}

function Update-WorkspaceXml {
    param(
        [string]$WorkspacePath,
        [string]$FlutterSdkPath
    )

    if (-not (Test-Path $WorkspacePath)) {
        return
    }

    try {
        [xml]$workspace = Get-Content -Raw -Path $WorkspacePath
    }
    catch {
        Write-Warning "Could not parse .idea\workspace.xml. Leaving it untouched."
        return
    }

    $changed = $false

    $runManager = @($workspace.project.component | Where-Object { $_.name -eq "RunManager" }) | Select-Object -First 1
    if ($runManager) {
        $staleAndroidConfigs = @($runManager.configuration | Where-Object { $_.type -eq "AndroidRunConfigurationType" })
        foreach ($configuration in $staleAndroidConfigs) {
            [void]$runManager.RemoveChild($configuration)
            $changed = $true
        }
    }

    if ($FlutterSdkPath) {
        $flutterSettings = @($workspace.project.component | Where-Object { $_.name -eq "FlutterSettings" }) | Select-Object -First 1
        if (-not $flutterSettings) {
            $flutterSettings = $workspace.CreateElement("component")
            $flutterSettings.SetAttribute("name", "FlutterSettings")
            [void]$workspace.project.AppendChild($flutterSettings)
            $changed = $true
        }

        $flutterSdkOption = @($flutterSettings.option | Where-Object { $_.name -eq "flutterSdkPath" }) | Select-Object -First 1
        if (-not $flutterSdkOption) {
            $flutterSdkOption = $workspace.CreateElement("option")
            $flutterSdkOption.SetAttribute("name", "flutterSdkPath")
            [void]$flutterSettings.AppendChild($flutterSdkOption)
            $changed = $true
        }

        if ($flutterSdkOption.value -ne $FlutterSdkPath) {
            $flutterSdkOption.SetAttribute("value", $FlutterSdkPath)
            $changed = $true
        }
    }

    if ($changed) {
        $workspace.Save($WorkspacePath)
    }
}

$resolvedProjectRoot = Resolve-Path $ProjectRoot
$root = $resolvedProjectRoot.Path
$projectName = Split-Path -Leaf $root
$ideaDir = Join-Path $root ".idea"
$androidDir = Join-Path $root "android"
$moduleFileName = "$projectName.iml"
$moduleFilePath = Join-Path $root $moduleFileName

if (-not (Test-Path (Join-Path $root "pubspec.yaml"))) {
    Fail "Run this from the Flutter project root, the folder that contains pubspec.yaml."
}

if (-not (Test-Path $androidDir)) {
    Fail "This Flutter project has no android directory to link as a Gradle project."
}

if (
    -not (Test-Path (Join-Path $androidDir "settings.gradle")) -and
    -not (Test-Path (Join-Path $androidDir "settings.gradle.kts"))
) {
    Fail "android/settings.gradle or android/settings.gradle.kts was not found."
}

New-Item -ItemType Directory -Force -Path $ideaDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ideaDir "runConfigurations") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ideaDir "libraries") | Out-Null

Write-Step "Cleaning stale IntelliJ module files."
Get-ChildItem -Path $ideaDir -Filter "*.iml" -File -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Path $root -Filter "*.iml" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -ne $moduleFilePath } |
    Remove-Item -Force

$flutterSdk = Find-FlutterSdk -Root $root
if (-not $flutterSdk) {
    Write-Warning "Flutter SDK was not found. Dart SDK library metadata will not be regenerated."
}

Write-Step "Writing project module metadata."
$moduleXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://`$MODULE_DIR`$">
      <sourceFolder url="file://`$MODULE_DIR`$/lib" isTestSource="false" />
      <sourceFolder url="file://`$MODULE_DIR`$/test" isTestSource="true" />
      <excludeFolder url="file://`$MODULE_DIR`$/.dart_tool" />
      <excludeFolder url="file://`$MODULE_DIR`$/.pub" />
      <excludeFolder url="file://`$MODULE_DIR`$/build" />
    </content>
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
  </component>
  <component name="PubRoot">
    <roots>
      <root url="file://`$MODULE_DIR`$" />
    </roots>
  </component>
</module>
"@
Save-Utf8 -Path $moduleFilePath -Content $moduleXml

$modulesXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://`$PROJECT_DIR`$/$moduleFileName" filepath="`$PROJECT_DIR`$/$moduleFileName" />
    </modules>
  </component>
</project>
"@
Save-Utf8 -Path (Join-Path $ideaDir "modules.xml") -Content $modulesXml

Write-Step "Linking the Android Gradle project."
$gradleXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="GradleMigrationSettings" migrationVersion="1" />
  <component name="GradleSettings">
    <option name="linkedExternalProjectsSettings">
      <GradleProjectSettings>
        <option name="testRunner" value="CHOOSE_PER_TEST" />
        <option name="externalProjectPath" value="`$PROJECT_DIR`$/android" />
        <option name="gradleJvm" value="$GradleJvm" />
        <option name="modules">
          <set>
            <option value="`$PROJECT_DIR`$/android" />
            <option value="`$PROJECT_DIR`$/android/app" />
          </set>
        </option>
      </GradleProjectSettings>
    </option>
  </component>
</project>
"@
Save-Utf8 -Path (Join-Path $ideaDir "gradle.xml") -Content $gradleXml

$miscXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ExternalStorageConfigurationManager" enabled="true" />
  <component name="ProjectRootManager" version="2">
    <output url="file://`$PROJECT_DIR`$/out" />
  </component>
</project>
"@
Save-Utf8 -Path (Join-Path $ideaDir "misc.xml") -Content $miscXml

$androidProjectSystemXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="AndroidProjectSystem">
    <option name="providerId" value="com.android.tools.idea.GradleProjectSystem" />
  </component>
</project>
"@
Save-Utf8 -Path (Join-Path $ideaDir "AndroidProjectSystem.xml") -Content $androidProjectSystemXml

Write-Step "Writing a Flutter main.dart run configuration."
$runConfigXml = @"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="main.dart" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="filePath" value="`$PROJECT_DIR`$/lib/main.dart" />
    <method />
  </configuration>
</component>
"@
Save-Utf8 -Path (Join-Path $ideaDir "runConfigurations\main_dart.xml") -Content $runConfigXml

$deploymentTargetSelectorXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="deploymentTargetSelector">
    <selectionStates>
      <SelectionState runConfigName="main.dart">
        <option name="selectionMode" value="DROPDOWN" />
      </SelectionState>
    </selectionStates>
  </component>
</project>
"@
Save-Utf8 -Path (Join-Path $ideaDir "deploymentTargetSelector.xml") -Content $deploymentTargetSelectorXml

if ($flutterSdk) {
    Write-Step "Regenerating Dart SDK library metadata."
    $dartLibRoot = Join-Path $flutterSdk "bin\cache\dart-sdk\lib"
    $dartRoots = Get-ChildItem -Path $dartLibRoot -Directory |
        Sort-Object Name |
        ForEach-Object { "      <root url=`"$(Escape-Xml (To-IdeaFileUrl $_.FullName))`" />" }

    $dartSdkXml = @"
<component name="libraryTable">
  <library name="Dart SDK">
    <CLASSES>
$($dartRoots -join "`r`n")
    </CLASSES>
    <JAVADOC />
    <SOURCES />
  </library>
</component>
"@
    Save-Utf8 -Path (Join-Path $ideaDir "libraries\Dart_SDK.xml") -Content $dartSdkXml
}

$packageConfigPath = Join-Path $root ".dart_tool\package_config.json"
if (Test-Path $packageConfigPath) {
    Write-Step "Regenerating Dart package library metadata."
    $packageConfig = Get-Content -Raw -Path $packageConfigPath | ConvertFrom-Json
    $packageConfigDir = Split-Path -Parent $packageConfigPath
    $packageRoots = New-Object System.Collections.Generic.List[string]

    foreach ($package in $packageConfig.packages) {
        $packageRoot = Resolve-PackageConfigPath -BaseDirectory $packageConfigDir -UriText $package.rootUri
        if (-not $packageRoot) {
            continue
        }

        $packagePath = $packageRoot
        if ($package.packageUri) {
            $packagePath = [System.IO.Path]::GetFullPath((Join-Path $packageRoot ($package.packageUri.Replace("/", "\"))))
        }

        if (Test-Path $packagePath) {
            $packageRoots.Add($packagePath)
        }
    }

    $dartPackageRootXml = $packageRoots |
        Sort-Object -Unique |
        ForEach-Object { "      <root url=`"$(Escape-Xml (To-IdeaFileUrl $_))`" />" }

    $dartPackagesXml = @"
<component name="libraryTable">
  <library name="Dart Packages">
    <CLASSES>
$($dartPackageRootXml -join "`r`n")
    </CLASSES>
    <JAVADOC />
    <SOURCES />
  </library>
</component>
"@
    Save-Utf8 -Path (Join-Path $ideaDir "libraries\Dart_Packages.xml") -Content $dartPackagesXml
}
else {
    Write-Warning ".dart_tool\package_config.json was not found. Run flutter pub get, then run this repair again."
}

Update-WorkspaceXml -WorkspacePath (Join-Path $ideaDir "workspace.xml") -FlutterSdkPath $flutterSdk

Write-Step "Done. Reopen the Flutter root folder in Android Studio, then sync Gradle."
