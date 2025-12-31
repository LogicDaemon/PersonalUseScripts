;https://www.autohotkey.com/board/topic/74753-create-hardlinks/
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa363860
;https://learn.microsoft.com/en-gb/windows/win32/api/winbase/nf-winbase-createhardlinkw
CreateHardLink(ByRef existingFileName, ByRef linkFileName) {
    Return DllCall( "CreateHardLink", "Str", linkFileName, "Str", existingFileName, "Int", 0)
}

; If (A_LineFile == A_ScriptFullPath) {
;     If (A_Args.Length() != 2) {
;         MsgBox % "This script requires exactly 2 parameters (existing path, hardlink path), but it received " A_Args.Length() "."
;         ExitApp
;     }
;     ExitApp CreateHardLink(A_Args[1], A_Args[2])
; }
