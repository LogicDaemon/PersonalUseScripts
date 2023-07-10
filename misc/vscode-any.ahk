#NoEnv
;  - Visual Studio Code
; ahk_class Chrome_WidgetWin_1
; ahk_exe Code.exe

SetTitleMatchMode RegEx
GroupAdd vscode, - Visual Studio Code$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code\.exe
GroupAdd vscode, - Visual Studio Code - Insiders$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code - Insiders.exe

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

Run "%A_AhkPath%" "%A_ScriptDir%\vscode.insiders.ahk" %scriptcmdln%

ExitApp

#include <ParseScriptCommandLine>
