;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

errors := 0
names := {}
Loop Read, %A_ScriptDir%\Bloatware.txt
{
	commentStart := InStr(A_LoopReadLine, "#")
	pidOrName := Trim(commentStart ? SubStr(A_LoopReadLine, 1, commentStart - 1) : A_LoopReadLine)
	If (pidOrName)
		names[Format("{:L}", pidOrName)] := ""
}

allProc := []
For procpid, procpath in ProcessList(ProcessList_ReturnTrue) {
	SplitPath procpath, procexename
	If (names.HasKey(Format("{:L}", procexename)))
		pids[procpid] := procexename
}

For pid, exename in pids {
	If (SetEfficiencyMode(pid)) {
		FileAppend, Efficiency mode set for %exename% PID %pid%.`n, **
	} Else {
		FileAppend, Failed to set efficiency mode for PID %pid%. Error: %A_LastError%`n, **
		errors++
	}
}

ExitApp errors

#include <ProcessList>
#include <SetEfficiencyMode>
