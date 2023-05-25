(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    CHCP 65001
    IF EXIST rclone_to_YD.log CALL :RenameLog rclone_to_YD.log -remains
    ECHO. >rclone_to_YD.log
    COMPACT /C rclone_to_YD.log
    SET "errorRename="
)
(
    CALL bisync_with_YD.cmd "V:\Distributives" --filters-file "%~dp0rclone-filters.txt" --log-file "rclone_to_YD.log" %* || SET "errorRename=1"
    COMPACT /C /F /EXE:LZX rclone_to_YD.log
    IF DEFINED errorRename (
        REN "rclone_to_YD.log" "%~dp0rclone_to_YD.error%DATE:/=_%_%TIME::=_%.log"
    ) ELSE (
        MOVE /Y rclone_to_YD.log rclone_to_YD.last_ok.log
    )
    EXIT /B
)

:RenameLog <path> <suffix>
@(
SETLOCAL ENABLEDELAYEDEXPANSION
SET "timesuffix=%~t1"
SET "timesuffix=!timesuffix::=!"
SET "timesuffix=!timesuffix:/=!"
SET "timesuffix=!timesuffix:\=!"
)
@(
ENDLOCAL
SETLOCAL
SET newname="%%~n1%~2%timesuffix%%%~x1"
)
(
REN %%A "%newname%"
@START "" /B COMPACT /C /F /EXE:LZX "%~dp1%newname%"
@EXIT /B
)
