@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET baseScripts=\Scripts
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
)
@IF NOT DEFINED workdir SET "workdir=%srcpath%\temp"
@IF NOT DEFINED logsDir SET "logsDir=%workdir%"
@(
    MKDIR "%workdir%" 2>NUL
    IF EXIST "%workdir%dixmlsetup.exe" DEL "%workdir%dixmlsetup.exe"
    CURL -sRL -D- -z "%srcpath%\dixmlsetup.exe" -o "%workdir%dixmlsetup.exe" http://www.runtime.org/dixmlsetup.exe >"%logsDir%curl.log"
    FOR %%A IN ("%workdir%dixmlsetup.exe") DO @(
        IF "%%~zA" EQU 0 (
            DEL "%%~A"
            EXIT /B
        )
    )
    COMP "%srcpath%\dixmlsetup.exe" "%workdir%dixmlsetup.exe" /M >NUL
    IF NOT ERRORLEVEL 1 (
        DEL "%workdir%dixmlsetup.exe"
        EXIT /B
    )
    MOVE /Y "%workdir%dixmlsetup.exe" "%srcpath%\dixmlsetup.exe.tmp"
    MOVE /Y "%srcpath%\dixmlsetup.exe.tmp" "%srcpath%\dixmlsetup.exe"
)
