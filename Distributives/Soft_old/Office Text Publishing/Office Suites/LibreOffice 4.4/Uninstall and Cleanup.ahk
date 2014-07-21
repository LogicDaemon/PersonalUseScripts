#NoEnv

if not A_IsAdmin
{
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

;see http://wpkg.org/LibreOffice for list of GUIDs
Loop HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, 2
{
    RegRead URLInfoAbout, %A_LoopRegKey%, %A_LoopRegSubKey%\%A_LoopRegName%, URLInfoAbout
    If URLInfoAbout != http://www.documentfoundation.org
	Continue

    RegRead DisplayName, %A_LoopRegKey%, %A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
    If (SubStr(DisplayName, 1, 12)!="LibreOffice ")
	Continue
    
    RegRead InstallLocation, %A_LoopRegKey%, %A_LoopRegSubKey%\%A_LoopRegName%, InstallLocation
    If (SubStr(InstallLocation,1,28)!="C:\Program Files\LibreOffice" && SubStr(InstallLocation,1,34)!="C:\Program Files (x86)\LibreOffice")
	Continue
    
    RunWait MsiExec.exe /X%A_LoopRegName% /quiet /norestart
    FileRemoveDir %InstallLocation%, 1
}
