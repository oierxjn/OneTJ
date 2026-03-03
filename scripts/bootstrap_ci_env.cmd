@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bootstrap_ci_env.ps1" %*
exit /b %ERRORLEVEL%
