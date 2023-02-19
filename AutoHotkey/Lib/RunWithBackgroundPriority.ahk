;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

If (A_LineFile == A_ScriptFullPath) { ; this is direct invocation, not inclusion
    EnvGet LocalAppData,LOCALAPPDATA
    EnvGet SystemRoot,SystemRoot
    EnvGet debug, debug
    
    ExitApp RunWithBackgroundPriority(ParseScriptCommandLine())
}

RunWithBackgroundPriority(ByRef cmdline, ByRef dir := "", ByRef runOptions := "UseErrorLevel") {
    global debug
    
    If (debug)
        FileAppend PROCESS_MODE_BACKGROUND_BEGIN..., *
    DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00100000) ; PROCESS_MODE_BACKGROUND_BEGIN=0x00100000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
    If (debug)
        FileAppend return code %A_LastError%`nStarting %cmdline%..., *
    Run %cmdline%, %dir%, %runOptions%, pid
    If (debug)
        FileAppend PID %pid% [ERRORLEVEL %ERRORLEVEL% return code %A_LastError%]`nPROCESS_MODE_BACKGROUND_END, *
    DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00200000) ; PROCESS_MODE_BACKGROUND_END=0x00200000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
    If (debug)
        FileAppend return code %A_LastError%`n, *
    
    return pid
}

ExitApp %pid%

#include <ParseScriptCommandLine>
