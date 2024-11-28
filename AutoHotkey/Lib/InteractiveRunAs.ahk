;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

InteractiveRunAs(runCmdLine := "") {
    If (runCmdLine == "")
        runCmdLine := DllCall( "GetCommandLine", "Str" )
    EnvGet Unattended, Unattended
    If (!Unattended) {
        EnvGet RunInteractiveInstalls, RunInteractiveInstalls
        Unattended := RunInteractiveInstalls=="0"
    }
    If (Unattended)
        Throw Exception("Asked to RunAs, but running Unattended",-1,runCmdLine)
    Else
        Run *RunAs %runCmdLine%
}

If (A_LineFile == A_ScriptName) { ; Invoked stand-alone
    Try {
        InteractiveRunAs(ParseScriptCommandLine())
        ExitApp %ErrorLevel%
    } Catch e
        FileAppend e.What ? e.What : 1, *, CP1
}

#include %A_LineFile%\..\ParseScriptCommandLine.ahk
