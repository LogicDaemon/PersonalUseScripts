#NoEnv
#SingleInstance Force

CommandLine := DllCall( "GetCommandLine", "Str" )
CmdlArgs := SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+1)

Loop
{
    f := FileOpen(A_MyDocuments "\urls.log", "rw")
    If (f)
        Break
    ToolTip Could not open urls.log
    Sleep 3000
}
f.Seek(-StrLen(CmdlArgs) - 2, 2) ; SEEK_END=2 Move back from the end
contents := f.Read()
If (InStr(contents, CmdlArgs)) {
    TrayTip Same as the last in urls.log, %CmdlArgs%,, 0x12
} Else {
    f.Write(CmdlArgs "`n")
    ; 0x1 Info icon
    ; 0x10 Windows XP and later: Do not play the notification sound.
    TrayTip Added to urls.log, %CmdlArgs%,, 0x11
}
