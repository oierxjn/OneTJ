@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check_ci.ps1" %*
exit /b %ERRORLEVEL%
