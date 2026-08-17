@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0flutter_analyze_app.ps1" %*
exit /b %ERRORLEVEL%
