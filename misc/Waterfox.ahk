#NoEnv

GroupAdd waterfox, ahk_exe waterfox.exe

If (!A_Args.Length() && WinExist("ahk_group waterfox")) {
    If(WinActive())
        WinActivateBottom ahk_group waterfox
    Else
        WinActivate
} Else {
    EnvGet LocalAppData, LocalAppData
    ShellRun(LocalAppData "\Programs\Waterfox\waterfox.exe", GetScriptCommandLine())

    WinWait ahk_group waterfox
    WinActivate
}

ExitApp

#include <ShellRun from Installer>
#include <GetScriptCommandLine>
