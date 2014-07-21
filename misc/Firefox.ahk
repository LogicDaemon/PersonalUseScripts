#NoEnv

GroupAdd firefox, ahk_exe firefox.exe

If (!A_Args.Length() && WinExist("ahk_group firefox")) {
    If(WinActive())
        WinActivateBottom ahk_group firefox
    Else
        WinActivate
} Else {
    ShellRun(A_ProgramFiles "\Mozilla Firefox\firefox.exe", GetScriptCommandLine())
    WinWait ahk_group firefox
    WinActivate
}

ExitApp

#include <ShellRun by Lexikos>
#include <GetScriptCommandLine>
