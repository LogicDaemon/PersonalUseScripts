@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "localdist=d:\Distributives\Drivers\VIA\USB 3.0"
IF NOT DEFINED ErrorCmd SET ErrorCmd=PAUSE
IF NOT DEFINED exe7z CALL :find7zexe
IF NOT DEFINED exe7z PAUSE & SET "exe7z=PAUSE & ECHO "

SET "tempdst=%TEMP%\%~n0_VIA_XHCI_Driver"
SET "distmask=VIA_XHCI_Driver_V*.zip"
CALL :InitRemembering
)
IF EXIST d:\ (
    IF NOT EXIST "%localdist%" MKDIR "%localdist%"
    XCOPY "%srcpath:~0,-1%" "%localdist%" /E /I /Y && SET "srcpath=%localdist%\"
)
FOR /R "%~dp0" %%I IN ("%distmask%") DO IF /I "%%~nxI" NEQ "dpinst.7z" CALL :RememberIfLatest dstfname "%%~fI"
%exe7z% x -r -aoa -o"%tempdst%\*" -- "%dstfname%"||%ErrorCmd%

SET "notinstalled=1"
FOR /R "%tempdst%" %%I IN ("*.exe") DO (
    SET "notinstalled=0"
    START "" /B /WAIT /D "%%~dpI" "%%~I" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
)
IF "%notinstalled%"=="1" (
    ECHO Installer executable not found.
    EXIT /B 1
) ELSE (
    ECHO Install finished, error code: %ERRORLEVEL%
    RD /S /Q "%tempdst%"
)
EXIT /B

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

:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve /reg:64`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)
)

EXIT /B
:checkDirFrom1stArg <arg1> <anything else>
    CALL :Check7zDir "%~dp1"
EXIT /B

:Check7zDir <dir>
    IF NOT "%~1"=="" SET dir7z=%~1
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" >NUL 2>&1 <NUL || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)

:findexe
    (
    REM %1 variable which will get location
    REM %2 executable file name with optional suggested path
    REM %3... additional paths with filename (including masks) to look through
    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.

    SET "locvar=%~1"
    SET "seekforexecfname=%~nx2"
    )
    (
    REM checking simplest variant -- when suggested path exists or executable is in %PATH%
    FOR /D %%I IN ("%~dp2") DO IF EXIST "%%~I%seekforexecfname%" CALL :testexe %locvar% "%%~I%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM checking paths suggestions
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    FOR /R "%SystemDrive%\SysUtils" %%I IN (.) DO IF EXIST "%%~I\%seekforexecfname%" CALL :testexe %locvar% "%%~I\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM following is relative to containing-script-location
    CALL :testexe %locvar% "%srcpath%..\..\..\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Server.local\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & (
	    IF NOT ERRORLEVEL 9009 EXIT /B
	    IF ERRORLEVEL 9010 EXIT /B
	)
	SHIFT /3
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
