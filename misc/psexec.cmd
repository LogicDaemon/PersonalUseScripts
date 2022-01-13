@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "suffix="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "suffix=64"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "suffix=64"
    
    SET "destDir=%LOCALAPPDATA%\Programs\SysInternals"
)
(
    IF NOT EXIST "%destDir%" MKDIR "%destDir%"
    IF EXIST "%destDir%\%~n0%suffix%.exe.bak" DEL "%destDir%\%~n0%suffix%.exe.bak"
    CURL -RO -z "%destDir%\%~n0.chm" https://live.sysinternals.com/%~n0.chm
    CURL -R -o "%destDir%\%~n0%suffix%.exe.new" -z "%destDir%\%~n0%suffix%.exe" https://live.sysinternals.com/%~n0%suffix%.exe
    IF EXIST "%destDir%\%~n0%suffix%.exe.new" (
        MOVE /Y "%destDir%\%~n0%suffix%.exe.new" "%destDir%\%~n0%suffix%.exe" || (
            MOVE /Y "%destDir%\%~n0%suffix%.exe" "%destDir%\%~n0%suffix%.exe.bak"
            MOVE /Y "%destDir%\%~n0%suffix%.exe.new" "%destDir%\%~n0%suffix%.exe"
        ) || MOVE /Y "%destDir%\%~n0%suffix%.exe.bak" "%destDir%\%~n0%suffix%.exe"
    )
    ENDLOCAL
    "%LOCALAPPDATA%\Programs\SysInternals\%~n0%suffix%.exe" %*
)
