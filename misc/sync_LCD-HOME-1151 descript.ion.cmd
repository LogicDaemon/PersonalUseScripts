@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem https://superuser.com/a/411570
CALL "%~dp0_unison_get_command.cmd"
)
@(
SET "syncprog=%unisongui%"
CALL "%~dp0sync_LCD-HOME-1151.cmd" -ignore "Name *.*" -ignorenot "Name descript.ion" -prefer "socket://localhost:10355/v:/Distributives" %*
)
