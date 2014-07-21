#NoEnv
#SingleInstance off

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

Temp=%A_Temp%\LibO

RunWait 7zg x -o"%Temp%" LibO_3.4.4_Win_x86_install_multi.exe,, UseErrorLevel
If ErrorLevel
{
    FileAppend Error unpacking install: %ErrorLevel%, *
} Else {
    RunWait "%Temp%\setup.exe" /a, %Temp%, UseErrorLevel
    FileAppend Error running setup.exe: %ErrorLevel%, *
    ;/msoreg=1 will force registration of LibreOffice as default application for Microsoft Office formats;
    ;/msoreg=0 will suppress registration of LibreOffice as default application for Microsoft Office formats.
}
FileRemoveDir %Temp%, 1
