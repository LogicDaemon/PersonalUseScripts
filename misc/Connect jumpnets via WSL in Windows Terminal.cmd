@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

)
%LocalAppData%\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe nt -p Debian bash -lc "set -ex\;cd $HOME\;read jumpnets\;while ! proxy\;do sleep 3\;done\;while ! proxycdn\;do sleep 3\;done"
