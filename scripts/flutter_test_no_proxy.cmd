@echo off
setlocal

powershell -ExecutionPolicy Bypass -File "%~dp0flutter_test_no_proxy.ps1" %*
exit /b %ERRORLEVEL%
