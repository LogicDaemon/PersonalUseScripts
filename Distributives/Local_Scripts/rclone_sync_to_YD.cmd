@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    CHCP 65001
    IF EXIST rclone_to_YD.log MOVE /Y rclone_to_YD.log rclone_to_YD.log.bak
    ECHO. >rclone_to_YD.log
    COMPACT /C rclone_to_YD.log
    SET "errorRename="
)
(
    rclone sync "V:\Distributives" "YD:Distributives" --timeout 60m -v --delete-excluded --filter-from "%~dp0rclone-filters.txt" --log-file "%~dp0rclone_to_YD.log" || SET "errorRename=1"
    COMPACT /C /F /EXE:LZX rclone_to_YD.log
    IF DEFINED errorRename (
        MOVE "%~dp0rclone_to_YD.log" "%~dp0rclone_to_YD.error%DATE:/=_%_%TIME::=_%.log"
    )
)
rem --filter "- **/temp/**" --filter "- Soft_old/**" --filter "- %~n0.log" 
