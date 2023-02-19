@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

rem     SET "USERPROFILE=C:\Users\WDAGUtilityAccount"
rem     SET "APPDATA=C:\Users\WDAGUtilityAccount\AppData\Roaming"
)
(

    IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" (
        MKDIR "%APPDATA%\GHISLER"
        CALL :copy_config
    )
    "%~dp0tc.cmd"
    EXIT /B
)

:copy_config
    IF NOT EXIST "%USERPROFILE%\AppData_Host\Roaming\GHISLER\wincmd.ini" (
        ping -n 2 127.0.0.1 >NUL
        GOTO :copy_config
    )
    XCOPY "%USERPROFILE%\AppData_Host\Roaming\GHISLER" "%APPDATA%\GHISLER" /E /C /I /G /H /Y
EXIT /B
