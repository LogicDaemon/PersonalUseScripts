﻿#NoEnv
;  - Visual Studio Code
; ahk_class Chrome_WidgetWin_1
; ahk_exe Code.exe

SetTitleMatchMode RegEx
;GroupAdd vscode, - Visual Studio Code$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code\.exe
GroupAdd vscode, - Visual Studio Code - Insiders$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code - Insiders.exe

installScripts := [A_ScriptDir "\vscode-insiders-update.ahk"]

scriptcmdln := ParseScriptCommandLine()
If (!scriptcmdln && WinExist("ahk_group vscode")) {
    If (WinActive())
        WinActivateBottom ahk_group vscode
    Else
        WinActivate
    ExitApp
}

If (!scriptcmdln) {
    ToolTip Checking for VS Code Insiders update...
    RunWait "%A_AhkPath%" "%A_ScriptDir%\vscode-insiders-update.ahk"
    ToolTip
}
EnvGet LocalAppData, LocalAppData
Loop {
    If (vscodeexe := FirstExisting( LocalAppData "\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
                                  , LocalAppData "\Programs\VS Code Insiders\Code - Insiders.exe"
                                  , ProgramFiles "\Microsoft VS Code Insiders\Code - Insiders.exe" ))
        break
    If (A_Index > installScripts.Count())
        Throw Exception("VS Code is neither found nor can be installed")
    If (FileExist(installScript := installScripts[A_Index]))
        RunWait % installScript,, Min UseErrorLevel
}
SplitPath vscodeexe,, vscodedir
EnvGet PATH, PATH
EnvSet PATH, %PATH%;%vscodedir%
PrependPaths()
Run "%vscodeexe%" %scriptcmdln%

; If (!WinExist("ahk_group vscode") && ((removehp && RegWriteUserEnv("http_proxy", "")) + (removehps && RegWriteUserEnv("https_proxy", "")))) ; + is like OR but with mandatory execution for both args
;     EnvUpdate    

ExitApp

#include %A_LineFile%\..\vscode.lib.ahk
#include <RegWriteUserEnv>
#include <ParseScriptCommandLine>
