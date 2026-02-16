#Warn
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

scoopBaseDir := FindScoopBaseDir()
logPath := scoopBaseDir "\apps_update.log"

mode = Min
For _, v in A_Args {
	If (v == "/hide") {
		mode := "Hide"
	} Else {
		FileAppend Unknown argument: %v%, **
		If (mode != "Hide")
			MsgBox 0x10, %A_ScriptName%, Unknown argument: %v%
	}
}

; Cursor updater uses scoop, and it may update the bucket, so it must run
; before scoop updater. Also it relies on scoop cleanup ran separately.
If (FileExist(scoopBaseDir "\apps\cursor"))
	RunWait "%A_AhkPath%" "%A_ScriptDir%\update_cursor.ahk"

;RunWait scoop.cmd update -a,, Min
FileMove %logPath%, %logPath%_old, 1
RunScoopUpdates(scoopBaseDir, logPath, GetScoopPostUpdateScripts(), GetNoAutoUpdateApps(), mode)

RunWait "%A_AhkPath%" "%A_ScriptDir%\scoop_clean_cache.ahk"
Run DFHL.exe /l ., %LocalAppData%\Programs\scoop\shims, Min
Run DFHL.exe /l ., %scoopBaseDir%\cache, Min
ExitApp 

RunScoopUpdates(scoopBaseDir, logPath, scoopPostUpdateScripts, scoopNoAutoUpdate, runMode:="Hide") {
	local
	
	If (scoopNoAutoUpdate.Count() == 0) {
		; Use scoop update all if there are no exceptions
		updateAll := True
	} Else {
		; Check if any of the excepted apps actually installed.
		; If not, use scoop update all.
		updateAll := True
		For appName in scoopNoAutoUpdate {
			If (FileExist(scoopBaseDir "\apps\" appName)) {
				updateAll := False
				Break
			}

		}
	}

	If (updateAll) {
		FileAppend Updating all apps...`n, %logPath%, CP1
		RunWait %comspec% /C "scoop.cmd update -a >>"%logPath%" 2>&1",, %runMode%
		If (!ErrorLevel) {
			FileAppend Cleaning up all apps...`n, %logPath%, CP1
			RunWait %comspec% /C "scoop.cmd cleanup -a >>"%logPath%" 2>&1",, %runMode%
			updateAllSucceeded := True
		}
	}

	If (!updateAll || !updateAllSucceeded) {
	Loop Files, %scoopBaseDir%\apps\*.*, D
	{
		If (scoopNoAutoUpdate.HasKey(A_LoopFileName))
		Continue
		If (!updateAll) {
		FileAppend Updating %A_LoopFileName%...`n, %logPath%, CP1
		RunWait %comspec% /C "scoop.cmd update "%A_LoopFileName%" >>"%logPath%" 2>&1",, %runMode%
		If (ErrorLevel)
			Continue
		FileAppend Cleaning up %A_LoopFileName%...`n, %logPath%, CP1
		RunWait %comspec% /C "scoop.cmd cleanup "%A_LoopFileName%" >>"%logPath%" 2>&1",, %runMode%
		}
		postUpdateScript := scoopPostUpdateScripts[A_LoopFileName]
		If (IsFunc(postUpdateScript)) {
		FileAppend Running post-update script for %A_LoopFileName%...`n, %logPath%, CP1
		postUpdateScript.Call()
		} Else If (postUpdateScript) {
		FileAppend Running post-update script %postUpdateScript%...`n, %logPath%, CP1
		SplitPath postUpdateScript,,, scriptExt
		If (scriptExt = "reg")
			RunWait %comspec% /C "REG IMPORT "%A_LoopFileFullPath%\current\%postUpdateScript%" >>"%logPath%" 2>&1",, %runMode%
		Else If (scriptExt = "ahk")
			Run %comspec% /C ""%A_AhkPath%" "%A_LoopFileFullPath%\current\%postUpdateScript%" >>"%logPath%" 2>&1"
		Else
			Run %comspec% /C ""%A_LoopFileFullPath%\current\%postUpdateScript%" >>"%logPath%" 2>&1"
		}
	}
	}
	
	RunWait compact.exe /C "%logPath%",, %runMode%
}

GetScoopPostUpdateScripts() {
	Return { "python": "install-pep-514.reg"
   		, "qbittorrent": Func("DeleteFiles").Bind("*.pdb") }
}

GetNoAutoUpdateApps() {
	local
	SplitPath A_ScriptName,,,,scriptNameNoExt
	Return ReadTxtToSet(A_ScriptDir "\" scriptNameNoExt "_noautoupdate.txt")
}

ReadTxtToSet(path) {
	local
	FileRead scoopNoAutoUpdateTxt, %path%
	scoopNoAutoupdate := {}
	For _, line in StrSplit(scoopNoAutoUpdateTxt, "`n")
		If (line)
			scoopNoAutoupdate[line] := ""
	Return scoopNoAutoupdate
}

DeleteFiles(masks*) {
	local
	
	For _, mask in masks {
		If (!InStr(mask, "*") && !InStr(mask, "?")
			&& InStr(FileExist(mask), "D")) {
			MsgBox 0x24, %A_ScriptName%, Delete %mask%?
			IfMsgBox Yes
				FileRemoveDir %mask%
			Continue
		}
		Loop Files, %mask%
		{
			MsgBox 0x24, %A_ScriptName%, Delete %A_LoopFileFullPath%?
			IfMsgBox Yes
				FileDelete %A_LoopFileFullPath%
		}
	}
}

#include <FindScoopBaseDir>
