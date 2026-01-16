; SetEfficiencyMode.ahk
; Sets efficiency mode (EcoQoS) and Idle priority for a specific process.

SetEfficiencyMode(pid) {
	Local
	; Constants
	Static PROCESS_POWER_THROTTLING_CURRENT_VERSION := 1
	Static PROCESS_POWER_THROTTLING_EXECUTION_SPEED := 0x1
	Static ProcessPowerThrottling := 4
	Static PROCESS_QUERY_INFORMATION := 0x0400
	Static PROCESS_SET_INFORMATION := 0x0200
	Static IDLE_PRIORITY_CLASS := 0x00000040

        If (!pid)
            pid := DllCall("GetCurrentProcessId")

	; Open process with QUERY and SET information rights
	hProcess := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION | PROCESS_SET_INFORMATION, "Int", 0, "UInt", pid, "Ptr")
	If (!hProcess)
		return 0

	; Set Priority Class to IDLE (Base Priority 4)
	; This matches the behavior of the python example
	DllCall("SetPriorityClass", "Ptr", hProcess, "UInt", IDLE_PRIORITY_CLASS)

	; Prepare PROCESS_POWER_THROTTLING_STATE structure
	; struct PROCESS_POWER_THROTTLING_STATE {
	;   ULONG Version;
	;   ULONG ControlMask;
	;   ULONG StateMask;
	; }
	VarSetCapacity(PowerThrottling, 12, 0)
	NumPut(PROCESS_POWER_THROTTLING_CURRENT_VERSION, PowerThrottling, 0, "UInt") ; Version
	NumPut(PROCESS_POWER_THROTTLING_EXECUTION_SPEED, PowerThrottling, 4, "UInt") ; ControlMask
	NumPut(PROCESS_POWER_THROTTLING_EXECUTION_SPEED, PowerThrottling, 8, "UInt") ; StateMask

	; Set Process Information to enable EcoQoS
	; BOOL SetProcessInformation(
	;   HANDLE                    hProcess,
	;   PROCESS_INFORMATION_CLASS ProcessInformationClass,
	;   LPVOID                    ProcessInformation,
	;   DWORD                     ProcessInformationSize
	; );
	; SetProcessInformation is available in Windows 8 and later, but ProcessPowerThrottling requires Windows 10 1709+
	result := DllCall("SetProcessInformation", "Ptr", hProcess, "Int", ProcessPowerThrottling, "Ptr", &PowerThrottling, "UInt", 12)

	DllCall("CloseHandle", "Ptr", hProcess)

	Return result
}

; Direct invocation support
; if (A_LineFile == A_ScriptFullPath) {
; 	if (A_Args.Length() == 0) {
; 		MsgBox Usage: %A_ScriptName% <PID>`n, *
; 		ExitApp 1
; 	}
; 	errors := 0
; 	For _, pid in A_Args {
; 		If pid is not integer
; 		{
; 			Process Exist, %pid%
; 			pid := ErrorLevel
; 		}
	
; 		If (SetEfficiencyMode(pid)) {
; 			FileAppend, Efficiency mode set for PID %pid%.`n, *
; 		} Else {
; 			FileAppend, Failed to set efficiency mode for PID %pid%. Error: %A_LastError%`n, *
; 			errors++
; 		}
; 	}
; 	ExitApp errors
; }

; #include %A_LineFile%\..\ProcessList.ahk
