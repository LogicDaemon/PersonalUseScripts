#Include <ShellRun by Lexikos>

; Shell.ShellExecute( _
;   ByVal sFile As BSTR, _
;   [ ByVal vArguments As Variant ], _
;   [ ByVal vDirectory As Variant ], _
;   [ ByVal vOperation As Variant ], _
;   [ ByVal vShow As Variant ] _
; ) As Integer

nprivRun(args*) {
;    Process Exist, Explorer.exe
;    If ErrorLevel
    If (!WinVer) {
	; From http://www.autohotkey.com/board/topic/54639-getosversion/
	;WinVer := ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF) "." (r >> 8)
	; for this purpose, only major version needed, and this way floating point avoided
	WinVer := ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF)
    }
    If ( WinVer >= 6 ) {
	ShellRun(args*)
    } Else {
	Executable := args[1]
	If (SubStr(Executable,1,1)!="""")
	    Executable="%Executable%"
	RunString := ( args[4] ? "*" . args[4] . " " : "" ) .  Executable . ( args[2] ? " " . args[2] : "" )
	Dir := args[3]
	ShowModes := ["Hide","", "Min", "Max"]
	ShowMode := ShowModes[args[5]-1]
	Run %RunString%, %Dir%, %ShowMode%
    }
}
