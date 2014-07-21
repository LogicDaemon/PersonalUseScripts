@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
REM TODO: determine OS, and run corresponding installer
IF NOT DEFINED ErrorCmd SET ErrorCmd=CALL :ErrorHandler
IF NOT DEFINED exe7z CALL :find7zexe

CALL :TryLocalCopy "d:\Distributives\Drivers\Realtek\Audio\High_Definition_Audio_Codecs"

IF "%~1"=="" (
    CALL :findSource || EXIT /B
) ELSE SET "source=%~1"

SET "log=%TEMP%\%~n0.log"
SET "setupwrittenlog=%SystemDrive%\RHDSetup.log"
SET "tempdst=%TEMP%\RealtekHDA-%~n0"
)
(
%exe7z% x -r -o"%tempdst%" -- "%source%"||%ErrorCmd%

PUSHD "%tempdst%" && (
    IF EXIST Guru3D.com CD Guru3D.com
    IF EXIST Setup* CD Setup*

    IF NOT EXIST setup.exe FOR /D %%I IN (*.*) DO (
rem 	IF EXIST "%%~I\WDM\setup.exe" CD "%%~I\WDM"
	IF EXIST "%%~I\setup.exe" CD "%%~I"
    )
    setup.exe -s -z || %ErrorCmd%
    REM /f2"%log%" doesn't work
POPD
)

RD /S /Q "%tempdst%"
MOVE /Y "%setupwrittenlog%" "%log%"
DEL "%SystemDrive%\csb.log" "%SystemDrive%\Install.log"

CALL "%~dp0RemoveFromStartup.cmd"
EXIT /B
)
:ErrorHandler
(
    ECHO Error %ERRORLEVEL% occured.
    PAUSE
EXIT /B
)
:findSource
(
    FOR /F "usebackq delims=" %%I IN (`DIR /O-D /B "%srcpath%*"`) DO (
	IF "%%~xI"==".exe" SET "source=%srcpath%.\%%~I" & EXIT /B
	IF "%%~xI"==".7z" SET "source=%srcpath%.\%%~I" & EXIT /B
	IF "%%~xI"==".zip" SET "source=%srcpath%.\%%~I" & EXIT /B
    )
EXIT /B 1
)
:TryLocalCopy <localDest>
(
IF EXIST "%~d1" (
    IF NOT EXIST %1 MKDIR %1
    XCOPY "%~dp0*.*" "%~1\" /E /C /I /H /K /Y && SET "srcpath=%~1\"
)
EXIT /B
)

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
    CALL :testexe %locvar% "%srcpath%..\..\..\..\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
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
