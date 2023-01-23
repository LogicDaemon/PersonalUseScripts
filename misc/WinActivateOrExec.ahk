#NoEnv

If (A_ScriptFullPath == A_LineFile) {
    cl_args := ParseScriptCommandLine()
    Menu Tray, Tip, %cl_args%
    If (WinActivateOrExec(A_Args[1], cl_args)) {
        ToolTip Activated %exe_path%
    } Else {
        Tooltip Started %cl_args%
    }
    Sleep 1000
    Tooltip
    ExitApp
}

WinActivateOrExec(ByRef exe_path, ByRef full_command_line := "", ByRef dir := "") {
    local
    SplitPath exe_path,exename,wd,ext
    If (dir == "")
        dir := wd
    ;MsgBox % exename ":" ext "`nUniqueID (0 if not exist): " (UniqueID := WinExist("ahk_exe" exename)) "`nWinActive? " WinActive("ahk_id" UniqueID)
    If ((UniqueID := WinExist("ahk_exe" exename)) && !WinActive("ahk_id" UniqueID)) {
        WinGet state, MinMax, ahk_exe %exename%
        If (state == -1)
            WinRestore ahk_exe %exename%
        WinActivate
        return true
    } Else {
        If (full_command_line == "")
            full_command_line = "%exe_path%"
        Run %full_command_line%,%dir%,, r_PID
        WinWait ahk_PID %r_PID%,,3
        If (ErrorLevel) ; Window has not appear, 3s timeout
            Return -1
        WinActivate
        return false
    }
}

#include <nprivRun>
#include <ParseScriptCommandLine>
