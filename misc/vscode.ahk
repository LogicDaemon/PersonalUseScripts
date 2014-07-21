#NoEnv
;  - Visual Studio Code
; ahk_class Chrome_WidgetWin_1
; ahk_exe Code.exe

SetTitleMatchMode RegEx
GroupAdd vscode, - Visual Studio Code$ ahk_class Chrome_WidgetWin_1 ahk_exe Code\.exe

vscodeRunning := WinExist("ahk_group vscode")

scriptcmdln := ParseScriptCommandLine()
If (vscodeRunning && !scriptcmdln) {
    If (WinActive())
        WinActivateBottom ahk_group ahk_group vscode
    Else
        WinActivate
} Else {
    EnvGet LocalAppData, LocalAppData
    vscodeexe := FirstExisting(LocalAppData "\Programs\Microsoft VS Code\Code.exe", LocalAppData "\Programs\VSCode\Code.exe")
    If (!vscodeRunning) {
        TrayTip,,Testing current environment connectivity (3s max)
        RunWait curl --connect-timeout 3 http://clients3.google.com/generate_204, %A_Temp%, Hide UseErrorLevel
        curlerr := %ErrorLevel%
        TrayTip

        If (curlerr) {
            removehp := RegWriteUserEnv("http_proxy", "%http_proxy_%", true)
            removehps := RegWriteUserEnv("https_proxy", "%https_proxy_%", true)
            If (removehp || removehps)
                EnvUpdate
        }
    }

    ShellRun(vscodeexe, scriptcmdln)
    
    If (!vscodeRunning && ((removehp && RegWriteUserEnv("http_proxy", "")) + (removehps && RegWriteUserEnv("https_proxy", "")))) ; + is like OR but with mandatory execution for both args
        EnvUpdate    
}

ExitApp

#include <RegWriteUserEnv>
#include <ParseScriptCommandLine>
#include <ShellRun by Lexikos>
