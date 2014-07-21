;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

;IfNotExist O:\
;    RunWait %comspec% /C RestartO.cmd

config := ProcessCLArgs( {"localisok": ["l", "localisok"]} )

EnvGet LOCALAPPDATA,LOCALAPPDATA
EnvSet syncprog, "%LOCALAPPDATA%\Programs\unison\unison 2.48.3 GTK.exe"

Try RunScript(A_ScriptDir "\sync_" A_ComputerName ".cmd"), localSynced := true

DriveGet DrivesF, List, FIXED
DriveGet DrivesR, List, REMOVABLE
Drives=%DrivesR%%DrivesF%

drivessynced := 0
Loop Parse, Drives
    Try RunScript(A_LoopField ":\Local_Scripts\sync_" A_ComputerName ".cmd"), synced++
If (!(drivessynced || (config.localisok && localSynced))) {
    icon := localSynced ? 0x30 : 0x10
    msgAppend := localSynced ? "`, but local computer sync script is started." : ""
    timeout := localSynced ? 15 : 0
    
    MsgBox % icon, % A_ScriptName, Sync scripts not found on any drives%msgAppend%, % timeout
}
ExitApp

RunScript(ByRef syncScript) {
    If (FileExist(syncScript)) {
        TrayTip Running script, %SyncScript%, 15, 1
        Run %comspec% /C %SyncScript%, %A_LoopField%:\Local_Scripts
        Sleep 3000
        TrayTip
    } Else {
        Throw Exception("Script not found",, syncScript)
    }
}
