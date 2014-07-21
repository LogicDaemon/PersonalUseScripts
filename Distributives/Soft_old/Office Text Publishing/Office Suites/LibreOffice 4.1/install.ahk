﻿#NoEnv
#SingleInstance ignore

global textTrayTip := "Installing LibreOffice"
Menu Tray, Tip, %textTrayTip%

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
if not A_IsAdmin
{
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp -1
    }
}

AhkParm=
If (!RunInteractiveInstalls)
    AhkParm=/ErrorStdOut

DistributiveMask=%A_ScriptDir%\LibreOffice_*_Win_x86.msi
HelpDistrMask=%A_ScriptDir%\LibreOffice_*_Win_x86_helppack_ru.msi

EnvGet LogPath,logmsi

RemoveLangpacks 	:= ReadListFromFile(A_ScriptDir . "\remove_langpacks.txt")
RemoveDictionaries 	:= ReadListFromFile(A_ScriptDir . "\remove_langpacks.txt")
RemoveOtherComponents 	:= ReadListFromFile(A_ScriptDir . "\remove_OtherComponents.txt")

Remove=%RemoveOtherComponents%`,%RemoveLangpacks%
;,%RemoveDictionaries%

; even    QuietInstall := /qb is interactive!!!!, so the only option is /qn
QuietInstall = /qn

;Searching distributives
Loop %DistributiveMask%
    If A_LoopFileFullPath > %Distributive% ; * is less than any digit, so mask will go away first
	Distributive:=A_LoopFileFullPath
If Not Distributive
    CheckError(-1, "Not found distributive with mask """ . DistributiveMask . """, workdir: """ . A_WorkingDir . """")

Loop %HelpDistrMask%
    If A_LoopFileFullPath > %HelpDistr% ; * is less than any digit, so mask will go away first
	HelpDistr=%A_LoopFileFullPath%
;If Not HelpDistr
;    CheckError(-1, "Not found helpfile distributive with mask """ . HelpDistrMask . """, workdir: """ . A_WorkingDir . """")

TrayTip %textTrayTip%, Running Check and close running soffice.bin.ahk
RunWait %A_AhkPath% /ErrorStdOut "%A_ScriptDir%\Check and close running soffice.bin.ahk"
TrayTip

TrayTip %textTrayTip%, Main MSI
ErrorsOccured := ErrorsOccured || InstallMSI(Distributive, QuietInstall . " COMPANYNAME=""группа компаний Цифроград"" ISCHECKFORPRODUCTUPDATE=0 REGISTER_ALL_MSO_TYPES=1 ADDLOCAL=ALL REMOVE=" . Remove . " AgreeToLicense=Yes")
FileSetAttrib +H, %A_DesktopCommon%\LibreOffice *

If (!ErrorsOccured) {
    If HelpDistr
    {
	TrayTip %textTrayTip%, Offline Help MSI
	ErrorsOccured := ErrorsOccured || InstallMSI(HelpDistr, QuietInstall)
    }
    IfExist Install_Extensions.ahk
    {
	Menu Tray, Tip, Installing Extensions
	TrayTip %textTrayTip%, Extensions
	RunWait "%A_AhkPath%" %AhkParm% Install_Extensions.ahk, %A_ScriptDir%, Min UseErrorLevel
	ErrorsOccured := ErrorsOccured || ErrorLevel
    }

    IfExist %A_ScriptDir%\SetDefaults.cmd
    {
	Menu Tray, Tip, Setting up defaults
	TrayTip %textTrayTip%, Setting up defaults
	RunWait %comspec% /C "%A_ScriptDir%\SetDefaults.cmd",%A_ScriptDir%,Min UseErrorLevel
	ErrorsOccured := ErrorsOccured || ErrorLevel
    }
}

Menu Tray, Tip, Compacting LibreOffice directory
TrayTip %textTrayTip%, Compacting LibreOffice directory
RunWait %comspec% /C ""%A_ScriptDir%\CompactLODir.cmd"",,Min

Exit ErrorsOccured

InstallMSI(MSIFileFullPath, params){
    Global LogPath
    
    ReturnErrValue=
    
    SplitPath MSIFileFullPath, MSIFileName
    If Not LogPath
	LogPath=%A_TEMP%\%MSIFileName%.log
    Menu Tray, Tip, Installing %MSIFileFullPath%
TryInstallAgain:
    RunWait msiexec.exe /i "%MSIFileFullPath%" %params% /norestart /l+* "%LogPath%",, UseErrorLevel
    
    If (ErrorLevel==1618) { ; Another install is currently in progress
	TrayTip %textTrayTip%, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	Sleep 30000
	GoTo TryInstallAgain
    }
    Menu Tray, Tip, %textTrayTip%
    
    return CheckError(ErrorLevel, MSIFileName)
    
    return %ReturnErrValue%
}

CheckError(ReturnErrValue, Description) {
    Global RunInteractiveInstalls,LogPath
    If ReturnErrValue!=0
    {
	FileAppend Error %ReturnErrValue% installing %Description%`nLog written to %LogPath%, *
	If RunInteractiveInstalls!=0
	    MsgBox 48, LibreOffice Installing error, ErrorLevel: %ReturnErrValue%`n%Description%, 30
    } else {
	FileAppend Finished installing %Description%`n, *
    }
    return ReturnErrValue
}

ReadListFromFile(filename) {
    out := ""
    Loop Read, %filename%
    {
	out .= "," . Trim(A_LoopReadLine," `t`n`r")
    }
    return SubStr(out, 2) ; skipping first comma
}
