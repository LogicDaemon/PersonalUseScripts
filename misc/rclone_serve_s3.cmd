@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
IF "%~1"=="" (
    ECHO Usage: %0 ^<bucket^> ^<mount_letter:^>
    EXIT /B 1
)
rclone.exe --vfs-cache-mode full mount s3:%*
)
