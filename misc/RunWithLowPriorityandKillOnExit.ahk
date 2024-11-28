;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon

CommandLine := DllCall( "GetCommandLine", "Str" )
CmdlArgs:= SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+2)

OnExit KillOnExit

Run %CmdlArgs%,,, aPID
Process Priority, %aPID%, L
Process WaitClose, %aPID%

KillOnExit:
Process Close, %aPID%
