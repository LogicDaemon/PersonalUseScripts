#NoEnv

CommandLine := DllCall( "GetCommandLine", "Str" )
CmdlArgs:= SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+1)

out=CmdlArgs: %CmdlArgs%`n

Loop %0%
{
    currentArg := %A_Index%
    out .= A_Index . ": " . currentArg
}

MsgBox %out%
