#NoEnv
#SingleInstance ignore

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
if not A_IsAdmin
{
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

AhkParm=
If (!RunInteractiveInstalls)
    AhkParm=/ErrorStdOut

DistributiveMask=%A_ScriptDir%\LibreOffice_*_Win_x86.msi
HelpDistrMask=%A_ScriptDir%\LibreOffice_*_Win_x86_helppack_ru.msi

EnvGet LogPath,logmsi

FileRead RemoveLangpacks,%A_ScriptDir%\remove_langpacks.txt
FileRead RemoveDictionaries,%A_ScriptDir%\remove_langpacks.txt
FileRead RemoveOtherComponents,%A_ScriptDir%\remove_OtherComponents.txt

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
If Not HelpDistr
    CheckError(-1, "Not found helpfile distributive with mask """ . HelpDistrMask . """, workdir: """ . A_WorkingDir . """")

RunWait %A_AhkPath% /ErrorStdOut "%A_ScriptDir%\Check and close running soffice.bin.ahk"

;Installing
ErrorsOccured := ErrorsOccured || InstallMSI(Distributive, QuietInstall . " COMPANYNAME=""Цифроград-Ставрополь`, ООО"" ISCHECKFORPRODUCTUPDATE=0 REGISTER_ALL_MSO_TYPES=1 ADDLOCAL=ALL REMOVE=" . Remove . " AgreeToLicense=Yes")
FileSetAttrib +H, %A_DesktopCommon%\LibreOffice *

If (!ErrorsOccured) {
    ErrorsOccured := ErrorsOccured || InstallMSI(HelpDistr, QuietInstall)
    RunWait "%A_AhkPath%" %AhkParm% Install_Extensions.ahk, %A_ScriptDir%, Min UseErrorLevel
    ErrorsOccured := ErrorsOccured || ErrorLevel

    EnvGet SetDefaults,SetDefaults
    If SetDefaults=0
	return

    RunWait %comspec% /C "%A_ScriptDir%\SetDefaults.cmd",%A_ScriptDir%,Min UseErrorLevel
    ErrorsOccured := ErrorsOccured || ErrorLevel
}

Exit ErrorsOccured

InstallMSI(MSIFileFullPath, params){
    Global LogPath
    
    ReturnErrValue=
    
    SplitPath MSIFileFullPath, MSIFileName
    If Not LogPath
	LogPath=%A_TEMP%\%MSIFileName%.log
    RunWait msiexec.exe /i "%MSIFileFullPath%" %params% /norestart /l+* "%LogPath%",, UseErrorLevel
    
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
