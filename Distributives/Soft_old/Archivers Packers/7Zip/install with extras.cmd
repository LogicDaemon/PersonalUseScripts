@REM coding:CP866
@ECHO OFF
REM Script to silently install 7-Zip, 7za and 7z_extra
REM to the same place and add it to %PATH%.
REM                   by LogicDaemon AKA AntICode <logicdaemon@gmail.com>

IF DEFINED PROCESSOR_ARCHITEW6432 IF NOT DEFINED installreentrance (
    SET installreentrance=1
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET distrib_main_mask=7z???.exe
SET distrib_extra_mask=7z???-extra.7z
SET distrib_7za_mask=7za???.zip

SET dest=%ProgramFiles%\7-Zip
IF EXIST "%SystemDrive%\SysUtils\UnxUtils\find.exe" SET unixfind=%SystemDrive%\SysUtils\UnxUtils\find.exe
IF DEFINED unixfind (
    FOR /F "usebackq delims=" %%I IN (`%unixfind% "%srcpath:~0,-1%" -name "%distrib_main_mask%"`) DO SET distrib_main=%%I
    FOR /F "usebackq delims=" %%I IN (`%unixfind% "%srcpath:~0,-1%" -name "%distrib_extra_mask%"`) DO SET distrib_extra=%%I
    FOR /F "usebackq delims=" %%I IN (`%unixfind% "%srcpath:~0,-1%" -name "%distrib_7za_mask%"`) DO SET distrib_7za=%%I
) ELSE (
    IF NOT DEFINED distrib_main FOR /R "%srcpath%" %%I IN ("%distrib_main_mask%") DO SET distrib_main=%%~dpnxI
    IF NOT DEFINED distrib_extra FOR /R "%srcpath%" %%I IN ("%distrib_extra_mask%") DO SET distrib_extra=%%~dpnxI
    IF NOT DEFINED distrib_7za FOR /R "%srcpath%" %%I IN ("%distrib_7za_mask%") DO SET distrib_7za=%%~dpnxI
)
IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=PAUSE"
    IF "%RunInteractiveInstalls%"=="0" SET "ErrorCmd=CALL :HandleError"
)

IF NOT DEFINED distrib_main %ErrorCmd%

CALL :find7zip
IF ERRORLEVEL 1 (
	CALL :MainInst
	CALL :find7zip||EXIT /B 1
)

REM First, extract all to make further comparsion
IF DEFINED distrib_7za %exe7z% x -aoa "%distrib_7za%" -o"%dest%"||%ErrorCmd%
IF DEFINED distrib_extra %exe7z% x -aoa "%distrib_extra%" -o"%dest%"||%ErrorCmd%
REM Then make a base to compare differences
IF DEFINED distrib_7za %exe7z% x -aoa -r- "%distrib_7za%" -o"%dest%\7za"||%ErrorCmd%
IF DEFINED distrib_extra %exe7z% x -aoa -r- "%distrib_extra%" -o"%dest%\extra"||%ErrorCmd%
REM And here installer overwrites some files
CALL :MainInst

REM TODO: rename&move or delete (if same) files from "%dest%\7za" and "%dest%\extra" to "%dest%"
PUSHD  "%dest%"||(%ErrorCmd% & GOTO :skipRemoveDups)
IF EXIST 7za CALL :DelSameMoveDiff 7za
IF EXIST extra CALL :DelSameMoveDiff extra
POPD
:skipRemoveDups

IF "%SetSystemSettings%"=="0" GOTO :skipSystemSettings
    ECHO ON
    CALL "%srcpath%associate.cmd"
:skipSystemSettings

EXIT /B

:DelSameMoveDiff
REM Subrirectories are silently removed!
PUSHD "%1"|| (%ErrorCmd% & EXIT /B)
FOR %%I IN ("*.*") DO (
  fc /B "%%I" "..\%%I" >NUL 2>&1
  
  REM One of compared files not exist or somethin more serious
  IF ERRORLEVEL 2 (%ErrorCmd%&EXIT /B)
  
  REM compared files differ
  IF ERRORLEVEL 1 (
    MOVE /Y "%%I" "..\%%~nI_%1%%~xI"||%ErrorCmd%
  ) ELSE (DEL "%%I"||%ErrorCmd%)
)
POPD
RD /S /Q "%1"||%ErrorCmd%

EXIT /B

:MainInst
    rem 64-bit check
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" GOTO :install64bit
    IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" GOTO :install64bit

    REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /d "%dest%" /f
    REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path32" /d "%dest%" /f
    rem 32-bit installer
    "%distrib_main%" /S /D="%dest%"||%ErrorCmd%
    GOTO :skip64bitInstall
    :install64bit
    CALL "%~dp0install 64bit msi.cmd"
    :skip64bitInstall
EXIT /B

:find7zip
    CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" || (ECHO  & EXIT /B 32767)
EXIT /B 1

:EchoErrorLevel
    ECHO Error: %ERRORLEVEL%
EXIT /B

:findexe
    (
    SET locvar=%1
    SET seekforexecfname=%~2
    )
    (
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
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
