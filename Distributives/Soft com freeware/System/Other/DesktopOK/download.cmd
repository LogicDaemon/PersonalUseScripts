@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET baseScripts=\Scripts
    CALL "%baseScripts%\_GetWorkPaths.cmd"
)
@IF NOT DEFINED workdir SET "workdir=%srcpath%\temp\"
@(
    MKDIR "%workdir%" 2>NUL
    CALL :download http://www.softwareok.com/Download/DesktopOK_Unicode.zip
    CALL :download http://www.softwareok.com/Download/DesktopOK_x64.zip
EXIT /B
)
:download <url>
@(
    IF EXIT "%workdir%%~nx1.tmp" DEL "%workdir%%~nx1.tmp" || EXIT /B
    CURL -RJL -o "%workdir%%~nx1.tmp" -z "%srcpath%%~nx1" %1 || EXIT /B
    IF NOT EXIST "%workdir%%~nx1.tmp" EXIT /B
    ECHO Moving "%workdir%%~nx1.tmp" to "%srcpath%%~nx1"
    MOVE /Y "%workdir%%~nx1.tmp" "%srcpath%%~nx1"
EXIT /B
)
