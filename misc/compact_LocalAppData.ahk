#NoEnv

cleanupScriptsBaseDir := A_ScriptDir
cleanupScripts :=   { "gobuild": ""
                    , "Chrome": "compact Chrome cache.cmd"
                    , "Firefox": "compact Firefox cache.cmd"
                    , "python": "compact_python_in_localappdata_programs.cmd" }
cleanupSet := {}, cleanupSetUndefined := true

For i, arg in A_Args {
    If (arg="/cleanup") {
        cleanup := true
    } Else If (cleanupScripts.HasKey(arg)) {
        cleanupSetUndefined := false
        cleanupSet[arg] := cleanupScripts[arg]
    } Else {
        FileAppend Unknown switch: %arg%`n, **, CP1
        ExitApp 128
    }
}
If (cleanupSetUndefined)
    cleanupSet := cleanupScripts

runningScripts := {}
For name, cleanupScript in cleanupSet {
    EnvSet cleanup, %cleanup%
    If (cleanupScript=="") {
        If (cleanup) {
            EnvGet LocalAppData,LocalAppData
            FileAppend %A_Now% Cleaning up %LocalAppData%\go-build ...`n, *, CP866
            FileRemoveDir %LocalAppData%\go-build, 1
            FileAppend %A_Now% `t...done (error %ErrorLevel%)`n, *, CP866
        }
    } Else {
        Run %comspec% /C "%cleanupScriptsBaseDir%\%cleanupScript%", %A_Temp%, Hide UseErrorLevel, rspid
        runningScripts[name] := rspid
        runningScriptsRemain := 1
        FileAppend %A_Now% Compacting %name%`, PID %rspid%`n, *, CP866
    }
}

If (runningScripts.Count()) {
    FileAppend %A_Now% Waiting for scripts to finish...`n, *, CP866
    While runningScripts.Count() {
        For name, rspid in runningScripts {
            If (rspid=="") {
                ; поскольку при удалении ключей, For … runningScripts может завершиться до того, как будут проверены все ключи, цикл надо будет повторить
                runningScripts.Delete(name)
            } Else {
                Process WaitClose, %rspid%, 1
                If (!ErrorLevel) {
                    FileAppend %A_Now% %name% finished compacting.`n, *, CP866
                    runningScripts[name] := ""
                }
            }
        }
    }
}
FileAppend %A_Now% `t...done`n, *, CP866
