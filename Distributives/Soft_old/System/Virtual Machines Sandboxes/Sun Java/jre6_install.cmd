@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF "%~1"=="" GOTO :SkipArg
SET Arg=%1
IF "%Arg:~,1%"=="/" GOTO :%Arg:~1%
:SkipArg

ECHO. >>"%TEMP%\jre_install.flag"
SET distfile=jre-6u*-windows-i586.exe
FOR /R "%~dp0" %%I IN ("%distfile%") DO SET distfile=%%~I

SET JREInstallLogParm=
IF DEFINED JREInstallLog SET JREInstallLogParm=/L %JREInstallLog%
"%distfile%" /s REBOOT=Suppress SPONSORS=0 DISABLEAD=1 %JREInstallLogParm%||SET InstallError=1
rem ADDLOCAL=ALL IEXPLORER=1 MOZILLA=1 JAVAUPDATE=0 AUTOUPDATECHECK=0 

:SettingsOnly
DEL "%TEMP%\jre_install.flag"
IF "%InstallError%"==1 (@ECHO &PAUSE)

SET reg=REG.exe
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET REG="%SYSTEMROOT%\SysWOW64\REG.EXE"

%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f
%REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

"%ProgramFiles%\Java\jre6\bin\jqs" -unregister

EXIT /B
