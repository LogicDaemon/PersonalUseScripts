@echo off
setlocal
REM Run this script from an admininistrator prompt to install NVIDIA ETW tracing

echo Installing NVIDIA Display Driver ETW Manifest manifest...

REM Uninstall existing manifest first
wevtutil.exe uninstall-manifest "ddETWExternal.xml"

REM Copy the ETW resource to system directory
xcopy /y /f ddETWExternal.dll %WINDIR%\System32\

REM Install the new manifest
wevtutil.exe install-manifest "ddETWExternal.xml"

REM Ensure that the provider was installed successfully
wevtutil get-publisher NVIDIA-DD-External > nul
