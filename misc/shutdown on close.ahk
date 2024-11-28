;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv

exename = %1%
If (!exename)
    exename = compact.exe

WinWaitClose ahk_exe %exename%
MsgBox 1, %A_ScriptName%, Shutting down in 5 min. OK to shut down immediately., % 5*60
IfMsgBox Cancel
    ExitApp
Shutdown 9
