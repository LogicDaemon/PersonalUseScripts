#NoEnv
port := (RandomShort() & 16383) + 49152

If (A_WorkingDir = A_WinDir "\System32") {
	FileCreateDir %A_MyDocuments%\Temp
	SetWorkingDir %A_MyDocuments%\Temp
}

;Run % FindOpenCodeExe() " --port " port " " ParseScriptCommandLine(),, Min
Run % FindOpenCodeExe() " web " ParseScriptCommandLine(),, Min
;Sleep 500
;Run http://localhost:%port%
ExitApp

; Generate a secure random 2-byte integer
RandomShort() {
	Static RtlGenRandom := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "Advapi32.dll", "Ptr"), "AStr", "SystemFunction036", "Ptr")
	ret := DllCall(RtlGenRandom, "UIntP", rand:=0, "Int", 2)
	If (ErrorLevel || !ret)
		Throw Exception("RtlGenRandom failed: " ErrorLevel,, A_LastError)
	Return rand
}

#include <ParseScriptCommandLine>
#include <FindOpenCodeExe>
