@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

ECHO Установка TeamViewer
ECHO Удалённо ("%1" - куда, если не указано, то локально)
ECHO "%2" - имя файла MSI из TeamViewerMSI.zip, если не указан, то  Host

REM -- some settings

SET "TempDirName=TeamViewer_Setup"
SET "DistributivesArchive=%srcpath%TeamViewerMSI.zip"
SET "SettingsScript=settings.cmd"
SET "MSIlog=%TEMP%\%~n0.log"

REM -- no changes below this line --
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)

IF "%~1"=="/CMDrestarted" ( SHIFT ) ELSE (
    IF /I %PROCESSOR_ARCHITECTURE% NEQ x86 (
	START "install.cmd run by 32-bit cmd.exe" /WAIT "%SystemRoot%\SysWOW64\cmd.exe" /C "%~f0" /CMDrestarted %*
	EXIT /B
    )
)

IF NOT DEFINED ErrorCmd (
    IF NOT "%RunInteractiveInstalls%"=="0" (
	SET "ErrorCmd=PAUSE"
    ) ELSE (
	SET "ErrorCmd=CALL :EchoErrorLevel"
    )
)

IF NOT DEFINED exe7z CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" || EXIT /B
IF %exe7z%=="" (
    ECHO 7-Zip не найден скриптом установки TeamViewer, возможна только локальная установка вручную.
    ECHO Все параметры командной строки игнорируются.
    %ErrorCmd%
    GOTO :LocalInstallNonZipped
)

SET "TempExtractPath=%TEMP%\%TempDirName%"

SET "desthost=%~1"
IF "%desthost%"=="" GOTO :SkipBackslashPrefixCheck
SET "taskkillRmt=/S %desthost%"
SET "remotesystem=%desthost%"
IF NOT "%desthost:~,2%"=="\\" SET "remotesystem=\\%desthost%"
:SkipBackslashPrefixCheck

SET "InstallMSI=%~2"
SET "RegConfigName=%~n2.reg"
rem SET "RemoveMSI="
IF "%InstallMSI%"=="" (
    IF /I "%~x1"==".MSI" (
	SET "InstallMSI=%~1"
	SET "RegConfigName=%~n1.reg"
	SET "remotesystem="
    ) ELSE (
	IF NOT "%remotesystem%"=="" (
	    SET "InstallMSI=TeamViewer_Host.MSI"
	    SET "RegConfigName=TeamViewer_host.reg"
	)
    )
)

IF "%InstallMSI%"=="" CALL :SelectInstallMSI

SET "PreExeCcmd="
IF NOT "%remotesystem%"=="" (
    SET "TempExtractPath=%remotesystem%\Admin$\Temp\%TempDirName%"
    START "" /B /WAIT /D"%TEMP%" c:\SysUtils\wget.exe -N --no-check-certificate http://live.sysinternals.com/psexec.exe
    REG ADD "HKEY_CURRENT_USER\Software\Sysinternals\PsExec" /v "EulaAccepted" /t REG_DWORD /d 1 /f
    SET PreExeCcmd="%TEMP%\psexec.exe" %remotesystem% -w "%SystemRoot%\Temp\%TempDirName%"
)

IF DEFINED PreExeCcmd SET "MSILog=%~n0.log"

IF NOT EXIST "%TempExtractPath%" MKDIR "%TempExtractPath%"
PUSHD "%TempExtractPath%" || GOTO :ExitWithError
    COPY /B /Y "%srcpath%%SettingsScript%"
    COPY /B /Y "%srcpath%PostFormData.ahk"
    COPY /B /Y "%srcpath%TeamViewer_host.defaults.reg" "%RegConfigName%"
    IF DEFINED DefaultsSource IF EXIST "%DefaultsSource%" %exe7z% e -aoa -- "%DefaultsSource%" "TeamViewer\%RegConfigName%"
    %exe7z% e -aoa -- "%DistributivesArchive%" %InstallMSI% %RemoveMSI%
    
    SC %remotesystem% STOP TeamViewer5
    ping 127.0.0.1 -n 5 >NUL 2>&1
    IF NOT DEFINED RemoveMSI GOTO :skipRemoveMSI

	%PreExeCcmd% "C:\Program Files (x86)\Teamviewer\Version5\TeamViewer_Service.exe" -uninstall
	%PreExeCcmd% "C:\Program Files\Teamviewer\Version5\TeamViewer_Service.exe" -uninstall
	%PreExeCcmd% "C:\Program Files (x86)\Teamviewer\Version5\install.exe"   -remove TEAMVIEWERVPN
	%PreExeCcmd% "C:\Program Files\Teamviewer\Version5\install.exe"   -remove TEAMVIEWERVPN
	ping 127.0.0.1 -n 5 >NUL 2>&1
	%SystemRoot%\System32\taskkill.exe %taskkillRmt% /F /IM TeamViewer_Service.exe
	%SystemRoot%\System32\taskkill.exe %taskkillRmt% /F /IM TeamViewer.exe

	%PreExeCcmd% cmd.exe /C RD /S /Q "C:\Program Files\Teamviewer\Version5"
	%PreExeCcmd% cmd.exe /C RD /S /Q "C:\Program Files (x86)\Teamviewer\Version5"
	%PreExeCcmd% cmd.exe /C IF EXIST "C:\Program Files\Teamviewer\Version5" MOVE /Y "C:\Program Files\Teamviewer\Version5\*" "C:\Program Files\Teamviewer"
	%PreExeCcmd% cmd.exe /C IF EXIST "C:\Program Files (x86)\Teamviewer\Version5" MOVE /Y "C:\Program Files (x86)\Teamviewer\Version5\*" "C:\Program Files (x86)\Teamviewer"
	rem 	Delete on reboot: C:\Program Files\Teamviewer\Version5\TeamViewer_Service.exe
	rem 	Delete on reboot: C:\Program Files\Teamviewer\Version5\
	
	%PreExeCcmd% cmd.exe /C msiexec.exe /x {118F5245-1999-4227-A12D-A0BB69A5E80B} /qn REBOOT=ReallySuppress>>"%MSILog%"
	IF ERRORLEVEL 1 SET "showlog=1"
	rem 	%PreExeCcmd% cmd.exe /C msiexec.exe /x "%RemoveMSI%" /qn REBOOT=ReallySuppress>>"%MSILog%"
	rem 	IF ERRORLEVEL 1 SET "showlog=1"
	
	%PreExeCcmd% "C:\Program Files\Teamviewer\Version5\uninstall.exe" -silent
	%PreExeCcmd% "C:\Program Files (x86)\Teamviewer\Version5\uninstall.exe" -silent
	
	ping 127.0.0.1 -n 5 >NUL 2>&1
:skipRemoveMSI
    %SystemRoot%\System32\taskkill.exe %taskkillRmt% /F /IM TeamViewer_Service.exe
    %SystemRoot%\System32\taskkill.exe %taskkillRmt% /F /IM TeamViewer.exe
    
    %PreExeCcmd% cmd.exe /C %SettingsScript% "%RegConfigName%"
    %PreExeCcmd% cmd.exe /C msiexec.exe /fa %InstallMSI% /quiet REBOOT=ReallySuppress /log+ "%MSILog%"
    %PreExeCcmd% cmd.exe /C msiexec.exe /i %InstallMSI% /quiet REBOOT=ReallySuppress /log+ "%MSILog%"
    IF ERRORLEVEL 1 SET "showlog=1"
    %PreExeCcmd% cmd.exe /C %SettingsScript% /PostInstall
    IF "%showlog%"=="1" (
	IF "%RunInteractiveInstalls%"=="0" (
	    TYPE "%MSILog%"
	) ELSE (
	    IF EXIST "%MSILog%" notepad "%MSILog%"
	)
    )
    DEL "%MSIlog%"
POPD
RD /S /Q "%TempExtractPath%"

EXIT /B
:ExitWithError
    ECHO Ошибка при установке, не удаётся перейти в удалённую папку
    %ErrorCmd%
EXIT /B

:SelectInstallMSI
    SET "listtemp=%temp%\%~n0.%RANDOM%.list"
    IF EXIST "%listtemp%" ECHO "%listtemp%" не должен существовать. & EXIT /B 2
    %exe7z% l -- "%DistributivesArchive%" *.MSI>"%listtemp%"
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "   Date      Time    Attr         Size   Compressed  Name" "%listtemp%"`) DO SET "skiplines=%%I"
    ECHO Доступны следующие варианты установки:
    ECHO 0 : Удалить TeamViewer_Host.msi, установить TeamViewer.msi
    SET "Counter=0"
    FOR /F "usebackq skip=%skiplines% tokens=6 delims= " %%I IN ("%listtemp%") DO (
	IF "%%~I"=="folders" GOTO :SelectInstallMSIExitFor
	CALL :AddMSIToList "%%~I"
    )
    :SelectInstallMSIExitFor
    DEL "%listtemp%"
    
    SET /P "MSINum=Выбранный вариант:"
    IF "%MSINum%"=="0" (
	SET "RemoveMSI=TeamViewer_Host.msi"
	SET "InstallMSI=TeamViewer.msi"
	SET "RegConfigName=TeamViewer.reg"
	EXIT /B
    )
    FOR /F "usebackq delims=" %%I IN (`ECHO %%MSI%MSINum%%%`) DO (
	SET "InstallMSI=%%I"
	SET "RegConfigName=%%~nI.reg"
    )
EXIT /B

:AddMSIToList
    SET /A "Counter+=1"
    SET "MSI%Counter%=%~1"
    ECHO %Counter% : %~1
EXIT /B

:LocalInstallNonZipped
ECHO 1. TeamViewer_Setup.exe
ECHO 2. TeamViewer_Host_Setup.exe
ECHO Любой другой вариант - выход
SET /P "InstallNum=: "
IF "%InstallNum%"=="1" START "" "%srcpath%TeamViewer_Setup.exe" /s
IF "%InstallNum%"=="2" START "" "%srcpath%TeamViewer5HostUnattended_egs.exe"
EXIT /B

:EchoErrorLevel
    ECHO ErrorLevel: %ErrorLevel%
EXIT /B

:findexe
    (
    SET "locvar=%~1"
    SET "seekforexecfname=%~2"
    )
    (
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3" == "" GOTO :testexe
	REM previous line causes attempt to exec %2 and EXIT /B 9009 to original caller
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B
