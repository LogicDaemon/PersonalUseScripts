@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

SET "size=%~1"
IF NOT DEFINED size SET /A "size=6*1024*1024"
)
START "" "%ProgramFiles%\ImDisk\RamDyn.exe" "R:" %size% -1 0 12 "-p \"/fs:ntfs /q /y\""
:wait
@(
MKDIR R:\Temp 2>NUL
IF EXIST R:\Temp EXIT /B
PING -n 2 127.0.0.1 >NUL
GOTO :wait
)
