param(
    [switch]$SkipBootstrap,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

if (-not $SkipBootstrap) {
    & (Join-Path $scriptDir "bootstrap_ci_env.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "bootstrap_ci_env.ps1 failed."
    }
}

Push-Location $repoRoot
try {
    & fvm flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "fvm flutter pub get failed." }

    & fvm flutter analyze lib test
    if ($LASTEXITCODE -ne 0) { throw "fvm flutter analyze failed." }

    if (-not $SkipTests) {
        & fvm flutter test --no-pub test
        if ($LASTEXITCODE -ne 0) { throw "fvm flutter test failed." }
    }
} finally {
    Pop-Location
}
