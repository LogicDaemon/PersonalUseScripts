@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF "%~1"=="" GOTO :SkipArg
SET Arg=%1
IF "%Arg:~,1%"=="/" GOTO :%Arg:~1%
:SkipArg

ECHO. >>"%TEMP%\jre_install.flag"
SET distmask=jre-8*-windows-i586.exe

CALL :InitRemembering
FOR /R "%~dp0" %%I IN ("%distmask%") DO CALL :RememberIfLatest dstfname "%%~fI"

SET JREInstallLogParm=
IF DEFINED JREInstallLog SET JREInstallLogParm=/L "%JREInstallLog%"
COPY /Y "%~dpn0.cfg" "%TEMP%\%~n0.cfg"
SET InstallError=0
"%dstfname%" INSTALLCFG="%TEMP%\%~n0.cfg" %JREInstallLogParm%||SET InstallError=1

:SettingsOnly
DEL "%TEMP%\jre_install.flag"

CALL "%~dp0HideStartMenuIcons.cmd"

REM Uninstall updater
msiexec.exe /x {4A03706F-666A-4037-7777-5F2748764D10} /qn

SET reg=REG.exe

REM installing 32-bit JRE. So, if we're on 64-bit windows, must use 32-bit REG.EXE
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET REG="%SYSTEMROOT%\SysWOW64\REG.EXE"

rem %REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f
%REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

SET ProgramFilesx86=%ProgramFiles%
IF DEFINED ProgramFiles^(x86^) SET "ProgramFilesx86=%ProgramFiles(x86)%"
FOR /D %%I IN ("%ProgramFilesx86%\Java\jre*") DO "%%~I\bin\jqs.exe" -unregister

EXIT /B %InstallError%

:InitRemembering
(
    SET "LatestDate=0000000000:00"
EXIT /B
)

:RememberIfLatest
(
    SET "CurrentDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "%~1=%~2"
	SET "LatestDate=%CurrentDate%"
    )
EXIT /B
