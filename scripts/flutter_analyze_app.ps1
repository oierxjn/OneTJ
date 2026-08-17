[CmdletBinding()]
param(
    [switch]$Strict,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterAnalyzeArgs
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

$qualityArgs = if ($Strict) {
    @('--fatal-warnings', '--fatal-infos')
} else {
    @('--no-fatal-warnings', '--no-fatal-infos')
}

Push-Location -LiteralPath $repoRoot
try {
    & fvm flutter analyze lib test @qualityArgs @FlutterAnalyzeArgs
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

exit $exitCode
