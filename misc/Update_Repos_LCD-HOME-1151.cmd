@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
START "" /B %comspec% /C "%~dp0sync_LCD-HOME-1151.cmd" -auto -batch

PUSHD "%USERPROFILE%\Projects\PersonalUseScripts" || EXIT /B
CALL update.cmd
git add .
git commit -m "Autoupdate"
)
