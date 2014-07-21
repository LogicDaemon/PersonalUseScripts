@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT EXIST "%LOCALAPPDATA%\Programs\SysUtils\SysInternals" MKDIR "%LOCALAPPDATA%\Programs\SysUtils\SysInternals"
    
    PUSHD "%LOCALAPPDATA%\Programs\SysUtils\SysInternals" || EXIT /B
        SET "suffix="
        IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "suffix=64"
        IF DEFINED PROCESSOR_ARCHITEW6432 SET "suffix=64"
)
(
        CURL -RO -z %~n0%suffix%.exe https://live.sysinternals.com/%~n0%suffix%.exe
        CURL -RO -z %~n0.chm https://live.sysinternals.com/%~n0.chm
    POPD
    ENDLOCAL
    "%LOCALAPPDATA%\Programs\SysUtils\SysInternals\%~n0%suffix%.exe" %*
)
