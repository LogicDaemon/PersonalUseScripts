#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    If ErrorLevel = ERROR
	Throw "Cannot acqure admin rights."
    Exit
}

If A_Is64bitOS
    distName=GoogleChromeStandaloneEnterprise64.msi
Else
    distName=GoogleChromeStandaloneEnterprise.msi

EnvGet logmsi, logmsi
If Not logmsi
    logmsi=%A_TEMP%\%distName%.log
RunWait msiexec.exe /i "%A_ScriptDir%\%distName%" /qn /l+* "%logmsi%", %A_ScriptDir%

FileSetAttrib +H, %A_DesktopCommon%\Google Chrome.lnk
RunWait %comspec% /C ""%A_ScriptDir%\copyDefaultSettings.cmd"", Min UseErrorLevel
