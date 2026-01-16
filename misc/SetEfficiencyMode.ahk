;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

if (A_Args.Length() == 0) {
	MsgBox Usage: %A_ScriptName% <PID or exename>...`n, *
	ExitApp 1
}

errors := 0
pids := {}
names := {}
For _, pidOrName in A_Args {
	If pidOrName is integer
	{
		pids[pidOrName] := -1
	} Else {
		names[Format("{:L}", pidOrName)] := ""
	}
}

allProc := []
For procpid, procpath in ProcessList(ProcessList_ReturnTrue) {
	SplitPath procpath, procexename
	If (!pids.HasKey(procpid) && names.HasKey(Format("{:L}", procexename)) || pids[procpid] == -1)
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
