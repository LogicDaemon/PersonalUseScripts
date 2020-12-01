@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    IF "%RunInteractiveInstalls%"=="0" (
	SET LogOffAfterInstall=0
	SET RebootAfterInstall=0
    )
    IF NOT DEFINED ActionAfterInstall IF NOT DEFINED LogOffAfterInstall IF NOT DEFINED LogOffAfterInstall (
	SET /P "ActionAfterInstall=После установки: 1 - перезагрузка, 2 - завершить сеанс, остальное - ничего: "
    )
)
(
    IF "%ActionAfterInstall%"=="1" SET "RebootAfterInstall=1"
    IF "%ActionAfterInstall%"=="2" SET "LogOffAfterInstall=1"
    )
    (
    FOR /D %%A IN ("%srcpath%cat\*.*") DO (
	ECHO %%A
	CALL "%srcpath%WU_cat_installsingle.cmd" "%%~A"
    )
)
(
IF "%LogOffAfterInstall%"=="1" shutdown /l
IF "%RebootAfterInstall%"=="1" shutdown /r
)
