@REM coding:OEM
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET installed=
SET switches=

IF EXIST "%~1\old.txt" (
    ECHO -- Old, skipping
    GOTO :skipinstall
)

IF EXIST "%~1\noauto.txt" (
    ECHO -- NoAutoInstall, skipping. Should shedule such dirs and install later manually.
    GOTO :skipinstall
)

IF EXIST "%~1\installer.cmd" (
    start "" /wait /D"%~1" cmd.exe /c installer.cmd
    SET installed=by installer.cmd
)

IF EXIST "%~1\switches.txt" FOR /F "usebackq delims=" %%k IN ("%~1\switches.txt") DO SET switches=%%k

REM IF "%switches%"=="" SET switches=-u -n -z
IF "%switches%"=="" SET switches=-q -n -z
IF "%installed%"=="" FOR %%l IN ("%~1\*.exe") DO (
	start "" /wait /D"%%~dpl" "%%~nxl" %switches%
	SET installed=*.exe %switches%
    )
IF "%installed%"=="" (
    ECHO ** Not installed - no files?
) ELSE (
    ECHO ++ Installed: %installed%
)
:skipinstall
