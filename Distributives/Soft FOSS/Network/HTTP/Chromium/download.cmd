@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
SET "distcleanup=1"
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"
)
(
rem Latest (may be broken): https://download-chromium.appspot.com/
rem CALL "%baseScripts%\_DistDownload.cmd" http://download-chromium.appspot.com//dl/Win *.zip -N -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-check-certificate >"%logsDir%dl-lock.flag"

rem Last Known Good: https://download-chromium.appspot.com/?platform=Win&type=continuous
CALL "%baseScripts%\_DistDownload.cmd" https://download-chromium.appspot.com/dl/Win?type=continuous *.zip -N -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-check-certificate >"%logsDir%dl-lock.flag"
DEL "%logsDir%dl-lock.flag"
)
