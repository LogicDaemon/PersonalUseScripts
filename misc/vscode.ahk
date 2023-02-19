#NoEnv
;  - Visual Studio Code
; ahk_class Chrome_WidgetWin_1
; ahk_exe Code.exe

SetTitleMatchMode RegEx
GroupAdd vscode, - Visual Studio Code$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code\.exe

vscodeRunning := WinExist("ahk_group vscode")
installScripts := [A_ScriptDir "\vscode-update.ahk"]

scriptcmdln := ParseScriptCommandLine()
If (vscodeRunning && !scriptcmdln) {
    If (WinActive())
        WinActivateBottom ahk_group vscode
    Else
        WinActivate
    ExitApp
}

EnvGet LocalAppData, LocalAppData
Loop {
    If (vscodeexe := FirstExisting(LocalAppData "\Programs\Microsoft VS Code\Code.exe", LocalAppData "\Programs\VS Code\Code.exe", ProgramFiles "\Microsoft VS Code\Code.exe"))
        break
    If (A_Index > installScripts.Count())
        Throw Exception("VS Code is neither found nor can be installed")
    If (FileExist(installScript := installScripts[A_Index]))
        RunWait % installScript,, Min UseErrorLevel
}
SplitPath vscodeexe,, vscodedir
EnvGet PATH, PATH
EnvSet PATH, %PATH%;%vscodedir%
Run "%vscodeexe%" %scriptcmdln%

; If (!vscodeRunning && ((removehp && RegWriteUserEnv("http_proxy", "")) + (removehps && RegWriteUserEnv("https_proxy", "")))) ; + is like OR but with mandatory execution for both args
;     EnvUpdate    

ExitApp

#include <RegWriteUserEnv>
#include <ParseScriptCommandLine>
