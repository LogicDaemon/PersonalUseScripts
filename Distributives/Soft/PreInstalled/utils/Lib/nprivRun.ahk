#Include <ShellRun from Installer>

; Shell.ShellExecute( _
;   ByVal sFile As BSTR, _
;   [ ByVal vArguments As Variant ], _
;   [ ByVal vDirectory As Variant ], _
;   [ ByVal vOperation As Variant ], _
;   [ ByVal vShow As Variant ] _
; ) As Integer

; Show = args[5]:
;  0 Open the application with a hidden window.
;  1 Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
;  2 Open the application with a minimized window.
;  3 Open the application with a maximized window.
;  4 Open the application with its window at its most recent size and position. The active window remains active.
;  5 Open the application with its window at its current size and position.
;  7 Open the application with a minimized window. The active window remains active.
; 10 Open the application with its window in the default state specified by the application.

nprivRun(args*) {
    ; Process Exist, Explorer.exe
    ; If ErrorLevel
    If (!WinVer) {
	; From http://www.autohotkey.com/board/topic/54639-getosversion/
	;WinVer := ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF) "." (r >> 8)
	; for this purpose, only major version needed, and this way floating point avoided
	WinVer := ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF)
    }
    If ( WinVer >= 6 ) {
	retval := ShellRun(args*)
    } Else {
        Executable := args[1]
        If (SubStr(Executable,1,1)!="""")
            Executable="%Executable%"
        RunString := ( args[4] ? "*" . args[4] . " " : "" ) .  Executable . ( args[2] ? " " . args[2] : "" )
        Dir := args[3]
        ShowModes := ["Hide","", "Min", "Max", "", "", "Min", ""]
        ShowMode := ShowModes[args[5]+1]
        Run %RunString%, %Dir%, %ShowMode%, retval
    }

    If (args[5] >= 1 && args[5] <= 3) {
	exepath:=args[1]
	WinWait ahk_exe %exepath%, , 3
	If (ErrorLevel) {
            TrayTip %exepath% started but no window found
	} Else {
            Sleep 50
            If (!WinActive()) {
                WinSet AlwaysOnTop, Toggle
                Sleep 5
                WinSet AlwaysOnTop, Toggle
                WinActivate
            }
	}
    }
}
