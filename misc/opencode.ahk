#NoEnv

If (A_WorkingDir = A_WinDir "\System32") {
	FileCreateDir %A_MyDocuments%\Temp
	SetWorkingDir %A_MyDocuments%\Temp
}

Run % FindTerminalAppCommand() A_Space FindOpenCodeExe() A_Space ParseScriptCommandLine()
ExitApp

#include <ParseScriptCommandLine>
#include <FindOpenCodeExe>
#include <FindTerminalAppCommand>
