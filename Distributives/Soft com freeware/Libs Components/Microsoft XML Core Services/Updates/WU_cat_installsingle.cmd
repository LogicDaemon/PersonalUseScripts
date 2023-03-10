@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET installed=
SET switches=
)
(
    IF EXIST "%~1\old.txt" (
	ECHO -- Old, skipping
	EXIT /B
    )

    IF EXIST "%~1\noauto.txt" (
	ECHO -- NoAutoInstall, skipping. Should shedule such dirs and install later manually.
	EXIT /B
    )

    IF EXIST "%~1\installer.cmd" (
	start "" /wait /D"%~1" cmd.exe /c "%~1\installer.cmd"
	SET "installed=by %~1\installer.cmd"
    )

    IF EXIST "%~1\switches.txt" FOR /F "usebackq delims=" %%k IN ("%~1\switches.txt") DO SET "switches=%%k"
    IF NOT DEFINED switches SET "switches=-q -n -z"
)
IF "%installed%"=="" FOR %%l IN ("%~1\*.exe") DO (
    start "" /wait /D"%%~dpl" "%%~fl" %switches%
    SET "installed=%~1\*.exe %switches%"
)
IF DEFINED installed (
    ECHO +++ Installed: %installed%
) ELSE (
    ECHO *** Not installed - no files?
)
