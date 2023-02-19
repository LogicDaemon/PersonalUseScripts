@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
)
:next
(
    plink -load proxy %1 -m "%USERPROFILE%\Documents\linux\add_my_auth_key.sh" || plink -load proxycdn %1 -m "%USERPROFILE%\Documents\linux\add_my_auth_key.sh"
    IF "%2"=="" EXIT /B
    SHIFT
    GOTO :next
)
