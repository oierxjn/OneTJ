@echo off
where fvm >nul 2>nul
if %ERRORLEVEL%==0 goto run_fvm

where dart >nul 2>nul
if %ERRORLEVEL%==0 goto run_dart

echo Neither "fvm" nor "dart" was found in PATH.
exit /b 1

:run_fvm
fvm dart scripts\update_app_version.dart %*
exit /b %ERRORLEVEL%

:run_dart
dart scripts\update_app_version.dart %*
exit /b %ERRORLEVEL%
