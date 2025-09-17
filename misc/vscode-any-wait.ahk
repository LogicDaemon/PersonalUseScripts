#NoEnv
#SingleInstance ignore
;  - Visual Studio Code
; ahk_class Chrome_WidgetWin_1
; ahk_exe Code.exe

SetTitleMatchMode RegEx
GroupAdd vscode, - Visual Studio Code$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code\.exe
GroupAdd vscodeinsiders, - Visual Studio Code - Insiders$ ahk_class ^Chrome_WidgetWin_1$ ahk_exe Code - Insiders.exe

EnvGet LocalAppData, LocalAppData
; Only check for Insiders paths if there's no release running
If (!WinExist("ahk_group vscode"))
    vscodeexe := FirstExisting( LocalAppData "\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
			      , LocalAppData "\Programs\VS Code Insiders\Code - Insiders.exe"
			      , ProgramFiles "\Microsoft VS Code Insiders\Code - Insiders.exe" )
; In all other cases (nothing running but no insiders installed, release running) check for release
If (!vscodeexe)
    vscodeexe := FirstExisting( LocalAppData "\Programs\Microsoft VS Code\Code.exe"
			      , LocalAppData "\Programs\VS Code\Code.exe"
			      , ProgramFiles "\Microsoft VS Code\Code.exe" )
If (!vscodeexe)
    Throw Exception("VS Code not found")
SplitPath vscodeexe,, vscodedir
EnvGet PATH, PATH
EnvSet PATH, %PATH%;%vscodedir%
PrependPaths()
scriptcmdln := ParseScriptCommandLine()
RunWait "%vscodeexe%" --wait %scriptcmdln%
ExitApp %ErrorLevel%

#include <ParseScriptCommandLine>
#include %A_LineFile%\..\vscode.lib.ahk
