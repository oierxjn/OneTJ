param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterTestArgs
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$childCommand = {
    param(
        [string]$RepoRoot,
        [string[]]$TestArgs
    )

    $env:NO_PROXY = 'localhost,127.0.0.1,::1'
    Remove-Item Env:HTTP_PROXY,Env:HTTPS_PROXY,Env:http_proxy,Env:https_proxy -ErrorAction SilentlyContinue
    Set-Location -LiteralPath $RepoRoot
    & fvm flutter test @TestArgs
    exit $LASTEXITCODE
}

& powershell -NoProfile -Command $childCommand -args $repoRoot, $FlutterTestArgs
exit $LASTEXITCODE
