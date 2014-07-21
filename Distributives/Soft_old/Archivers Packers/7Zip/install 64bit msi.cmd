@REM coding:CP866
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF NOT DEFINED logmsi SET logmsi=%TEMP%\7-Zip %~n0.log

SET dest=C:\Arc\7-Zip
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip" /v "Path" /d "%dest%" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip" /v "Path32" /d "%dest%" /f

SET distrib_msi_mask=7z*-x64.msi

IF EXIST "%SystemDrive%\SysUtils\UnxUtils\find.exe" SET unixfind=%SystemDrive%\SysUtils\UnxUtils\find.exe
IF DEFINED unixfind (
    FOR /F "usebackq delims=" %%I IN (`%unixfind% "%srcpath:~0,-1%" -name "%distrib_msi_mask%"`) DO SET distrib_msi=%%I
) ELSE (
    IF NOT DEFINED distrib_msi FOR /R "%srcpath%" %%I IN ("%distrib_msi_mask%") DO SET distrib_msi=%%~dpnxI
)

msiexec.exe /fav "%distrib_msi%" /qn /norestart /l+* "%logmsi%" INSTALLDIR="%dest%"
msiexec.exe /i "%distrib_msi%" /qn /norestart /l+* "%logmsi%" INSTALLDIR="%dest%"
