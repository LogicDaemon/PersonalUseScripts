#NoEnv
#SingleInstance off
Menu Tray, Tip, Installing Microsoft Security Essentials

if not A_IsAdmin
{
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

If A_OSVersion=WIN_XP
    Version=XP
Else If A_OSVersion in WIN_7,WIN_VISTA
{
    If A_Is64bitOS
	Version=64bit
    Else
	Version=32bit

} Else
    Exit

RunWait "%A_ScriptDir%\%Version%\mseinstall.exe" /s /runwgacheck /o, %A_ScriptDir%\%Version%
IfExist "%A_ScriptDir%\%Version%\mpam-fe.exe"
    Run "%A_ScriptDir%\%Version%\mpam-fe.exe" /s, %A_ScriptDir%\%Version%
