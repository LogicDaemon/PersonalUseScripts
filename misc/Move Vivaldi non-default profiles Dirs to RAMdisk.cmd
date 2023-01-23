@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED rd SET "rd=r:"
    FOR /F "usebackq delims=] tokens=1" %%I IN (`FIND /N "---separator---" "%~f0"`) DO SET "skip=%%~I"
)
@(
    SET /A "skip=%skip:~1%"
    
    IF "%~1"=="" (
        CALL :ProcProfile "%USERPROFILE%"
        EXIT /B
    )
)
:ProcProfile <path>
(
SET "sourceDir=%~1"
SET "destDir=%rd%%~pnx1"
)
@(
    PUSHD "%sourceDir%" && (
        FOR /F "usebackq skip=%skip% tokens=1,2 eol=; delims=*" %%I IN ("%~f0") DO @(
            FOR /D %%A IN ("%%~I*") DO (
                IF /I "%%~xA" NEQ ".bak" CALL :MoveDirToRAMDrive "%%~A%%~J"
            )
        )
        POPD
    )

EXIT /B
)
:MoveDirToRAMDrive <subdir path>
(
    MKDIR "%destDir%\%~1"
    IF EXIST "%sourceDir%\%~1\*" (
        IF NOT EXIST "%sourceDir%\%~1.bak" (
            MOVE /Y "%sourceDir%\%~1" "%sourceDir%\%~1.bak"
        ) ELSE (
            RD /S /Q "%sourceDir%\%~1"
        )
    )
    MKLINK /J "%sourceDir%\%~1" "%destDir%\%~1"
EXIT /B
)

REM Dir list
REM ---separator---
AppData\Local\Vivaldi\User Data\Profile *\AdBlockRules
AppData\Local\Vivaldi\User Data\Profile *\Cache
AppData\Local\Vivaldi\User Data\Profile *\Code Cache
AppData\Local\Vivaldi\User Data\Profile *\GPUCache
AppData\Local\Vivaldi\User Data\Profile *\Media Cache
; AppData\Local\Vivaldi\User Data\Profile *\Service Worker
