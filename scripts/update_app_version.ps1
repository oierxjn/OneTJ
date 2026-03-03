if (Get-Command fvm -ErrorAction SilentlyContinue) {
    fvm dart scripts/update_app_version.dart @args
    exit $LASTEXITCODE
}

if (Get-Command dart -ErrorAction SilentlyContinue) {
    dart scripts/update_app_version.dart @args
    exit $LASTEXITCODE
}

Write-Error "Neither 'fvm' nor 'dart' was found in PATH."
exit 1
