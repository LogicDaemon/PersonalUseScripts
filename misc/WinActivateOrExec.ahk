#NoEnv

args := ParseScriptCommandLine()
Menu Tray, Tip, %args%

cmd := A_Args[1]
SplitPath cmd,exename,wd,ext
;MsgBox % exename ":" ext "`nUniqueID (0 if not exist): " (UniqueID := WinExist("ahk_exe" exename)) "`nWinActive? " WinActive("ahk_id" UniqueID)
If (ext = "exe" && (UniqueID := WinExist("ahk_exe" exename)) && !WinActive("ahk_id" UniqueID)) {
    WinGet state, MinMax, ahk_exe %exename%
    If (state == -1)
        WinRestore ahk_exe %exename%
    WinActivate
    ToolTip % "Activated " cmd
} Else {
    Run %cmd%,,, r_PID
    WinWait ahk_PID %r_PID%,,3
    If (!ErrorLevel)
        WinActivate
    Tooltip Started and activated %tgt%
}

Sleep 1000
Tooltip
ExitApp

#include <nprivRun>
#include <ParseScriptCommandLine>
