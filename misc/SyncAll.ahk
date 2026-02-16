;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#Warn

;IfNotExist O:\
;    RunWait %comspec% /C RestartO.cmd

; Use -fastercheckUNSAFE when syncing Unison with a slow samba remote for the first time.
; Possibly with -path subdir also.

config := ProcessCLArgs( {"needADrive": "d"}, 0, True )
syncScriptArgs := syncProg := ""
For _, v in config[""] {
	If (v = "/text")
		syncProg := Which("unison.exe")
	Else
		syncScriptArgs .= " " v
}

If (!syncProg)
	EnvSet syncProg, % """" FindUnisonGuiOrText() """"

RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
syncScriptPath := A_ScriptDir "\sync_" hostname ".cmd"
Try RunScript(syncScriptPath, syncScriptArgs), localSynced := true

DriveGet DrivesF, List, FIXED
DriveGet DrivesR, List, REMOVABLE
Drives=%DrivesR%%DrivesF%

drivesSynced := false
Loop Parse, Drives
	Try RunScript(A_LoopField ":\Local_Scripts\sync_" hostname ".cmd", syncScriptArgs), synced++, drivesSynced := true
If (config.needADrive && !drivesSynced) {
	icon := localSynced ? 0x30 : 0x10
	, msgAppend := localSynced ? "`, but local computer sync script is started." : ""
	, timeout := localSynced ? 15 : 0
	
	MsgBox % icon, % A_ScriptName, Sync scripts not found on any drives%msgAppend%, % timeout
}
ExitApp

RunScript(ByRef syncScript, syncScriptArgs := "", runDir := "") {
	Local
	If (!FileExist(syncScript))
    	Throw Exception("Script not found",, syncScript)
	If (runDir == "")
    	runDir := A_Temp

	TrayTip Running script, %SyncScript%, 15, 1
	Run %comspec% /C "%syncScript% %syncScriptArgs%", %runDir%
	err := ErrorLevel
	If (err)
    	Sleep 3000
	TrayTip
	Return !err
}

FindUnisonGuiOrText() {
	Local
	unisonGUINames := ["unison-text+gui.exe", "unison-gui.exe", "unison-gtk2.exe", "unison-gtk.exe"]
	textsyncprog := Which("unison.exe")
	SplitPath textsyncprog,, shimDir
	If (FileExist(shimPath := shimDir "\unison.shim")) {
    	unisonShim := ReadScoopShim(shimPath)
    	textsyncprog := unisonShim["path"]
    	If (SubStr(textsyncprog, 1, 1) == """" && SubStr(textsyncprog, 0) == """")
        	textsyncprog := SubStr(textsyncprog, 2, -1)
	}
	If (!textsyncprog)
    	Throw Exception("Unison not found",, shimPath)
	
	SplitPath textsyncprog,, unisonDir
	For _, unisonGuiName in unisonGUINames {
    	If (FileExist(guisyncprog := unisonDir "\" unisonGuiName))
        	Return guisyncprog
	}
	Try Return Which(*unisonGUINames)
	
	Return textsyncprog
}

#include <ReadScoopShim>
#include <ProcessCLArgs>
#include <FindScoopBaseDir>
