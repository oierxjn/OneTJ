param(
    [string]$FlutterVersion = $env:FVM_FLUTTER_VERSION,
    [string]$OhosFlutterSdk = $env:OHOS_FLUTTER_SDK,
    [string]$OhosFlutterGitUrl = $env:OHOS_FLUTTER_GIT_URL,
    [string]$OhosFlutterGitRef = $env:OHOS_FLUTTER_GIT_REF
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($FlutterVersion)) {
    $FlutterVersion = "ohos_flutter"
}

if ([string]::IsNullOrWhiteSpace($OhosFlutterGitUrl)) {
    $OhosFlutterGitUrl = "https://gitcode.com/openharmony-tpc/flutter_flutter.git"
}

if ([string]::IsNullOrWhiteSpace($OhosFlutterGitRef)) {
    $OhosFlutterGitRef = "oh-3.27.4-dev"
}

$versionsDir = $null
if (-not [string]::IsNullOrWhiteSpace($env:FVM_VERSIONS_DIR)) {
    $versionsDir = $env:FVM_VERSIONS_DIR
} elseif (-not [string]::IsNullOrWhiteSpace($env:FVM_CACHE_PATH)) {
    $versionsDir = Join-Path $env:FVM_CACHE_PATH "versions"
} else {
    $versionsDir = Join-Path $HOME "fvm\versions"
}

if ([string]::IsNullOrWhiteSpace($OhosFlutterSdk)) {
    $OhosFlutterSdk = Join-Path $versionsDir $FlutterVersion
}

$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
$fvmrcPath = Join-Path $repoRoot ".fvmrc"
$localPropsPath = Join-Path $repoRoot "ohos\local.properties"

function Write-Log {
    param([string]$Message)
    Write-Host "[bootstrap_ci_env] $Message"
}

function Ensure-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Command '$Name' was not found in PATH."
    }
}

function Add-PubCacheBinToPath {
    $windowsPubBin = Join-Path $HOME "AppData\Local\Pub\Cache\bin"
    $linuxPubBin = Join-Path $HOME ".pub-cache/bin"
    if (Test-Path $windowsPubBin) {
        $env:PATH = "$windowsPubBin;$env:PATH"
    } elseif (Test-Path $linuxPubBin) {
        $env:PATH = "$linuxPubBin;$env:PATH"
    }
}

function Get-DartCommand {
    $systemDart = Get-Command dart -ErrorAction SilentlyContinue
    if ($systemDart) {
        return $systemDart.Source
    }

    $candidates = @(
        (Join-Path $OhosFlutterSdk "bin\dart.bat"),
        (Join-Path $OhosFlutterSdk "bin\dart.exe"),
        (Join-Path $OhosFlutterSdk "bin\dart")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Ensure-Fvm {
    if (Get-Command fvm -ErrorAction SilentlyContinue) {
        Write-Log "fvm found."
        return
    }

    Write-Log "fvm not found. Installing via dart pub global activate fvm."
    $dartCommand = Get-DartCommand
    if ($null -eq $dartCommand) {
        Write-Log "System dart not found. Bootstrapping OHOS Flutter SDK to use bundled dart."
        Ensure-OhosFlutterSdk
        $dartCommand = Get-DartCommand
    }
    if ($null -eq $dartCommand) {
        throw "No usable dart command found. Install dart or provide OHOS Flutter SDK."
    }

    & $dartCommand pub global activate fvm
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install fvm via dart."
    }

    Add-PubCacheBinToPath
    Ensure-Command "fvm"
    Write-Log "fvm installed."
}

function Has-FlutterBinary {
    param([string]$SdkPath)
    $batPath = Join-Path $SdkPath "bin\flutter.bat"
    $shPath = Join-Path $SdkPath "bin/flutter"
    return (Test-Path $batPath) -or (Test-Path $shPath)
}

function Ensure-OhosFlutterSdk {
    if (Has-FlutterBinary -SdkPath $OhosFlutterSdk) {
        Write-Log "OHOS Flutter SDK found: $OhosFlutterSdk"
        return
    }

    Ensure-Command "git"
    Write-Log "OHOS Flutter SDK not found. Cloning from $OhosFlutterGitUrl ($OhosFlutterGitRef)."

    if (Test-Path $OhosFlutterSdk) {
        throw "Path exists but is not a valid Flutter SDK: $OhosFlutterSdk"
    }

    $parent = Split-Path -Parent $OhosFlutterSdk
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $cloneArgs = @("clone")
    if (-not [string]::IsNullOrWhiteSpace($OhosFlutterGitRef)) {
        $cloneArgs += @("--branch", $OhosFlutterGitRef)
    }
    $cloneArgs += @($OhosFlutterGitUrl, $OhosFlutterSdk)

    & git @cloneArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone OHOS Flutter SDK."
    }
}

function Set-FvmVersion {
    $desired = "{`"flutter`":`"$FlutterVersion`"}`n"
    $current = ""
    if (Test-Path $fvmrcPath) {
        $current = Get-Content -Raw $fvmrcPath
    }
    if ($current -ne $desired) {
        Set-Content -Path $fvmrcPath -Value $desired -NoNewline
        Write-Log "Updated .fvmrc -> $FlutterVersion"
    } else {
        Write-Log ".fvmrc already points to $FlutterVersion"
    }
}

function Apply-FvmUse {
    Push-Location $repoRoot
    try {
        & fvm use $FlutterVersion --force --skip-pub-get
        if ($LASTEXITCODE -ne 0) {
            throw "fvm use failed for version '$FlutterVersion'."
        }
    } finally {
        Pop-Location
    }
    Write-Log "Project is configured to use '$FlutterVersion'."
}

function Update-OhosLocalProperties {
    $escapedSdk = $OhosFlutterSdk -replace "\\", "\\\\"
    $line = "flutter.sdk=$escapedSdk"
    $content = ""

    if (Test-Path $localPropsPath) {
        $content = Get-Content -Raw $localPropsPath
        if ($content -match "(?m)^flutter\.sdk=") {
            $content = [regex]::Replace($content, "(?m)^flutter\.sdk=.*$", $line)
        } else {
            if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) {
                $content += "`n"
            }
            $content += "$line`n"
        }
    } else {
        $content = "$line`n"
    }

    Set-Content -Path $localPropsPath -Value $content -NoNewline
    Write-Log "Updated ohos/local.properties flutter.sdk."
}

Ensure-Fvm
Ensure-OhosFlutterSdk
Set-FvmVersion
Apply-FvmUse
Update-OhosLocalProperties

Push-Location $repoRoot
try {
    & fvm flutter --version
    if ($LASTEXITCODE -ne 0) {
        throw "fvm flutter --version failed."
    }
} finally {
    Pop-Location
}

Write-Log "Environment bootstrap completed."
