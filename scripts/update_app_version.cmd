@echo off
where fvm >nul 2>nul
if %ERRORLEVEL%==0 (
  fvm dart scripts\update_app_version.dart %*
  exit /b %ERRORLEVEL%
)

where dart >nul 2>nul
if %ERRORLEVEL%==0 (
  dart scripts\update_app_version.dart %*
  exit /b %ERRORLEVEL%
)

echo Neither "fvm" nor "dart" was found in PATH.
exit /b 1
