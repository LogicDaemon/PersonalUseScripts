;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

;IfNotExist O:\
;    RunWait %comspec% /C RestartO.cmd

; Use -fastercheckUNSAFE when syncing Unison with a slow samba remote for the first time.
; Possibly with -path subdir also.

config := ProcessCLArgs( {"needADrive": "d"}, 0, True )
syncScriptArgs := ""
For i, v in config[""]
    syncScriptArgs .= " " v

EnvGet LOCALAPPDATA,LOCALAPPDATA
;EnvSet syncprog, "%LOCALAPPDATA%\Programs\unison\bin\unison-gtk2.exe"
guisyncprog=%LOCALAPPDATA%\Programs\unison\bin\unison-text+gui.exe
textsyncprog=%LOCALAPPDATA%\Programs\unison\bin\unison.exe
If (FileExist(guisyncprog)) {
    EnvSet syncprog, "%guisyncprog%"
} Else If (FileExist(textsyncprog)) {
    ;MsgBox "%syncprog%" does not exist`, falling back to "%textsyncprog%".
    EnvSet syncprog, "%textsyncprog%"
} Else {
    Throw Exception("Could not find unison-gui.exe or unison.exe")
}

RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
syncScriptPath := A_ScriptDir "\sync_" hostname ".cmd"
Try RunScript(syncScriptPath), localSynced := true

DriveGet DrivesF, List, FIXED
DriveGet DrivesR, List, REMOVABLE
Drives=%DrivesR%%DrivesF%

drivessynced := false
Loop Parse, Drives
    Try RunScript(A_LoopField ":\Local_Scripts\sync_" hostname ".cmd"), synced++, drivessynced := true
If (config.needADrive && !drivessynced) {
    icon := localSynced ? 0x30 : 0x10
    , msgAppend := localSynced ? "`, but local computer sync script is started." : ""
    , timeout := localSynced ? 15 : 0
    
    MsgBox % icon, % A_ScriptName, Sync scripts not found on any drives%msgAppend%, % timeout
}
ExitApp

RunScript(ByRef syncScript, runDir := "") {
    global syncScriptArgs
    If (runDir == "")
        runDir := A_Temp
    If (FileExist(syncScript)) {
        TrayTip Running script, %SyncScript%, 15, 1
        Run %comspec% /C "%syncScript%%syncScriptArgs%", %runDir%
        err := ErrorLevel
        If (err)
            Sleep 3000
        TrayTip
        Return !err
    } Else {
        Throw Exception("Script not found",, syncScript)
    }
}

#include <ProcessCLArgs>
