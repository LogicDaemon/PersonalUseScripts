@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET found=
    FOR /F "usebackq delims=" %%A IN ("%~dp0_Distributives.base_dirs.txt") DO @(
        IF EXIST "%%~A\%~2" (
            SET "found=%%~A" & GOTO :found
        ) ELSE IF EXIST "%%~A\Distributives\%~2" (
            SET "found=%%~A\Distributives" & GOTO :found
        )
    )
    EXIT /B 1
)
:found
@(
    ECHO %found%
    ENDLOCAL
    SET "%~1=%found%"
)
