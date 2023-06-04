;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

exename = %1%
If (!exename)
    exename = compact.exe

WinWaitClose ahk_exe %exename%
MsgBox 1, %A_ScriptName%, Shutting down in 5 min. OK to shut down immediately., % 5*60
IfMsgBox Cancel
    ExitApp
Shutdown 9
