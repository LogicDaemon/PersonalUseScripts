@REM coding:OEM
@REM ECHO OFF
REM                                     Automated software update scripts
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru

SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED workdir SET "workdir=%srcpath%\temp"
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

rem also releases.mozilla.org/pub/mozilla.org/thunderbird/releases/latest/win32/ru/
SET distURL=http://download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/win32/ru/
SET distfname=Thunderbird Setup 

IF NOT EXIST "%workdir%" MKDIR "%workdir%"
START "" /B /WAIT /D"%workdir%" "c:\SysUtils\wget.exe" -ml2 -H -nd -np -e robots=off -A.exe,.asc -o"%~n0.log" %distURL%
rem -DHreleases.mozilla.org,download.cdn.mozilla.net
DEL "%workdir%\Thunderbird Setup Stub *.exe"
FOR %%I IN ("%workdir%\*.exe") DO CALL :linkdst "%%~fI"
REM In FOR's, use "%%~I" because Win2K and XP differently set quotes around iterator variable:
REM 2K always outputs without quotes, but XP's 'FOR' double-quotes argument if it contains spaces.

EXIT /B

:linkdst
    SET SU_Aversion=%~n1
    REM len(%distfname%)=18
    SET SU_Aversion=%SU_Aversion:~18%
    REM linking
    SET "dst=%srcpath%%~n1 ru%~x1"
    IF NOT EXIST "%dst%" (
        REM try linking first, copy if failed
        "c:\SysUtils\xln.exe" "%~1" "%dst%"|| (ECHO Y | COPY /B /Y "%~1" "%dst%")
        SET "cleanup_action=DEL /F"
        CALL "%baseScripts%\distcleanup.cmd" "%~1"
        SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
        CALL "%baseScripts%\distcleanup.cmd" "%srcpath%%distfname%*.exe" "%dst%"
        REM Updating AutoUpdate Scripts
        IF DEFINED SUScripts MOVE "%SUScripts%\Mozilla Thunderbird *.cmd" "%SUScripts%\Mozilla Thunderbird %SU_Aversion%.cmd"
    )
EXIT /B
