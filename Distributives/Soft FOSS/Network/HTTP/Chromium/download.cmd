@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
)
(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    IF NOT EXIST "%workdir%" MKDIR "%workdir%"
    
    CALL :download "chrome-win.zip" "https://download-chromium.appspot.com/dl/Win?type=snapshots"
    CALL :download "chrome-win64.zip" "https://download-chromium.appspot.com/dl/Win_x64?type=snapshots"
EXIT /B
)
:download
IF EXIST "%workdir%%~nx1" (
    SET timeCond=-z "%workdir%%~nx1"
) ELSE IF EXIST "%srcpath%%~nx1" (
    SET timeCond=-z "%srcpath%%~nx1"
)
(
    CURL -vLpR %timeCond% -o "%workdir%%~nx1.tmp" %2 || EXIT /B
    IF NOT EXIST "%workdir%%~nx1.tmp" EXIT /B
    MOVE /Y "%workdir%%~nx1.tmp" "%workdir%%~nx1" || EXIT /B
    MKLINK /H "%srcpath%%~nx1.new" "%workdir%%~nx1" || (
        MOVE /Y "%workdir%%~nx1" "%srcpath%%~nx1"
        EXIT /B
    )
    MOVE /Y "%srcpath%%~nx1.new" "%srcpath%%~nx1"
EXIT /B
) >>"%logsDir%%~nx1.log" 2>&1


rem SET "distcleanup=1"
rem with -N, it says
    rem --2017-02-10 09:43:07--  https://download-chromium.appspot.com/dl/Win?type=snapshots
    rem Connecting to 192.168.127.1:3128... connected.
    rem Proxy request sent, awaiting response... 405 Method Not Allowed
    rem 2017-02-10 09:43:09 ERROR 405: Method Not Allowed.

rem SET wgetConf=-d -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-timestamping
REM --no-timestamping
REM --no-if-modified-since

