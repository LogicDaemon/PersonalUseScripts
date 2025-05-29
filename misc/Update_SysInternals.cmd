@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    PUSHD "%LocalAppData%\Programs\SysInternals" || EXIT /B
    FOR %%A IN ("*.*") DO @(
        IF "%%~xA"==".tmp" (
            DEL "%%~A"
        ) ELSE IF "%%~xA"==".replaced" (
        ) ELSE (
            ECHO Updating %%A
            CURL -svfR -z "%%~A" "https://live.sysinternals.com/%%~nxA" >"%%~nxA.tmp" || (
                ECHO Failed
                DEL "%%~nxA.tmp"
            )
            CALL :CheckRename "%%~nxA.tmp" "%%~nxA"
        )
    )
    EXIT /B
)
:CheckRename <tmp> <dest>
@(
    IF "%~z1"=="" EXIT /B
    IF %~z1 LSS 16384 EXIT /B
    IF NOT "%~z2"=="" CALL :CheckSizeDiff "%~z2" "%~z1" || EXIT /B
    MOVE /Y "%%~nxA.tmp" "%%~nxA" || (
        MOVE /Y "%%~nxA" "%%~nxA.replaced"
        MOVE /Y "%%~nxA.tmp" "%%~nxA"
    )
    EXIT /B
)
:CheckSizeDiff