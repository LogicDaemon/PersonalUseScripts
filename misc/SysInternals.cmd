@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED LOCALAPPDATA EXIT /B -1
    IF "%~x1"==".exe" CALL :usetemplate %1 & EXIT /B
    IF "%~x1"=="" CALL :usetemplate %1.exe & EXIT /B
    MKDIR "%LOCALAPPDATA%\Programs\SysInternals" 2>NUL
    PUSHD "%LOCALAPPDATA%\Programs\SysInternals" && (
	CURL -R -o "%LOCALAPPDATA%\Programs\SysInternals\%~1" "https://live.sysinternals.com/%~1"
	POPD
    )
    "%LOCALAPPDATA%\Programs\SysInternals"\%*
EXIT /B
)
:usetemplate
@(SETLOCAL ENABLEEXTENSIONS
    SET "args=%2 %3 %4 %5 %6 %7 %8"
    IF NOT EXIST "%~dp0%~n1.cmd" MKLINK /H "%~dp0%~n1.cmd" "%~dp0sysinternals_util_call_template.cmd" || ECHO N|COPY "%~dp0sysinternals_util_call_template.cmd" "%~dp0%~n1.cmd"
    IF "%~9"=="" (
        ENDLOCAL
        CALL "%~dp0%~n1.cmd" -nobanner %args%
        EXIT /B
    )
)
:nextArg
@(
    IF "%~9"=="" (
        ENDLOCAL
        CALL "%~dp0%~n1.cmd" -nobanner %args%
        EXIT /B
    )
    SET "args=%args% %9"
    SHIFT /9
    GOTO :nextArg
)
