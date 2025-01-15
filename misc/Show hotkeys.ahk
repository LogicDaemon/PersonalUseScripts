;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#InstallKeybdHook
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

myPID := DllCall("GetCurrentProcessId")
KeyHistory

GroupAdd myWin, ahk_pid %myPID%

Loop
{
    If (WinActive("ahk_group myWin")) {
        ;WinMenuSelectItem ahk_group myWin,, View, Refresh
        ControlSend,,{F5}
    }
    Sleep 1000
}

Esc::
    ExitApp
