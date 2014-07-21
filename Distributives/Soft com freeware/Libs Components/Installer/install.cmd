@ECHO OFF
SETLOCAL

FOR /F "usebackq delims=" %%W IN (`ver`) DO SET VW=%%W
REM Microsoft Windows XP [Version 5.1.2600]
IF "%VW:~0,22%"=="Microsoft Windows XP [" SET InstallerUpdateDistributive="%~dp0WindowsXP-KB942288-v3-x86.exe" -u -n -z
REM Microsoft Windows 2000 [Версия 5.00.2195]
IF "%VW:~0,24%"=="Microsoft Windows 2000 [" SET InstallerUpdateDistributive="%~dp0WindowsInstaller-KB893803-v2-x86.exe" -u -n -z
REM Microsoft Windows [Version 5.2.3790]
IF "%VW:~0,30%"=="Microsoft Windows [Version 5.2" SET InstallerUpdateDistributive="%~dp0WindowsServer2003-KB942288-v4-x86.exe" -u -n -z

IF NOT DEFINED InstallerUpdateDistributive (
    ECHO Windows version is unsupported:&ver
) ELSE (
    %InstallerUpdateDistributive%
)

ENDLOCAL
