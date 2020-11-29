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
        curlerr := -1
        TrayTip,,Testing current environment connectivity (3s max)
        SetTimer killCURL, -5000
        RunWait curl --connect-timeout 3 http://clients3.google.com/generate_204, %A_Temp%, UseErrorLevel, curlPID ; Hide 
        curlerr := ErrorLevel
        SetTimer killCURL, Off
        TrayTip
        
        If (curlerr) {
            ; removehp := RegWriteUserEnv("http_proxy", "%http_proxy_%", true)
            ; removehps := RegWriteUserEnv("https_proxy", "%https_proxy_%", true)
            ; If (removehp || removehps)
            ;     EnvUpdate
            ; EnvGet http_proxy, http_proxy_
            ; EnvGet https_proxy, https_proxy_
            Run %comspec% /C "%USERPROFILE%\Documents\Scripts\cntlm.cmd",,Min
            http_proxy := https_proxy := "http://localhost:63128/"
            EnvSet http_proxy, %http_proxy%
            EnvSet https_proxy, %https_proxy%
        }
    }

    Run "%vscodeexe%" %scriptcmdln%
    
    ; If (!vscodeRunning && ((removehp && RegWriteUserEnv("http_proxy", "")) + (removehps && RegWriteUserEnv("https_proxy", "")))) ; + is like OR but with mandatory execution for both args
    ;     EnvUpdate    
}

ExitApp

killCURL:
    Process Close, %curlPID%
ExitApp

#include <RegWriteUserEnv>
#include <ParseScriptCommandLine>
