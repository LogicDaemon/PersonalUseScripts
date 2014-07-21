;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force
#include <URIEncodeDecode>
SendMode Input

AutoTrim Off

clipBak:=ClipboardAll
Global runStage:=0, composeText
; 0 - init
; 1 - waiting for clipboard change
; 2+ - mail app started

Sleep 100

WinGetTitle WindowTitle,A

; " - Opera", " - Chromium", " - Nightly", " - Firefox", " - Mozilla Thunderbird", " - Google Chrome"
WindowTitle:=SubStr(WindowTitle,1,RegExMatch(WindowTitle, "i) -( [\w]+){1,2}$")-1)

If ( !( CopySelectionUsing("^{Ins}") || CopySelectionUsing("^c") ) ) {
    ToolTip Can't copy selection :(
}
Clipboard:=clipbak
runStage++

If (pathMT := GetExePath("thunderbird.exe")) {
    ToolTip Launching Thunderbird…
    Run % """" . pathMT . """ -compose ""subject='" . WindowTitle . "',body=" . UriEncode(composeText) . """"
} Else {
    ;ToolTip Launching mailto: URL…
    ;MsgBox % "mailto:?subject=" . UriEncode(WindowTitle) . "&body=" . UriEncode(composeText)
    ;Run "mailto:?subject=" . UriEncode(WindowTitle) . "&body=" . UriEncode(composeText)

    ;from http://stackoverflow.com/questions/6548570/url-to-compose-a-message-in-gmail-with-full-gmail-interface-and-specified-to-b
    ;example: https://mail.google.com/mail/?view=cm&fs=1&to=someone@example.com&su=SUBJECT&body=BODY&bcc=someone.else@example.com
    
    ToolTip Launching Gmail
;    Run % "https://mail.google.com/mail/?view=cm&fs=1&su=" . UriEncode(WindowTitle) . "&body=" . UriEncode(composeText)
;    Run % "https://mail.google.com/mail/?view=cm&su=" . UriEncode(WindowTitle) . "&body=" . UriEncode(composeText)
    Run % "https://mail.google.com/mail/u/1/?view=cm&su=" . UriEncode(WindowTitle) . "&body=" . UriEncode(composeText)
}

Sleep 3000
ToolTip
Exit

CopySelectionUsing(keycomb) {
    global runStage
    
    KeyWait Shift
    KeyWait Alt
    KeyWait Ctrl
    KeyWait LWin
    KeyWait RWin
    
    ToolTip Sending %keycomb%…
    runStage:=1
    Send %keycomb%
    Sleep 500
    return runStage==1 ; if runstage is still 1, OnClipboardChange did not happen -> return 1
}

OnClipboardChange:
    global runStage, composeText
    Critical 1000
    If (A_EventInfo==1 && runStage==1) { ; A_EventInfo==1 if the clipboard contains something that can be expressed as text
        If (IsFunc("CutTrelloURLs"))
            composeText := Func("CutTrelloURLs").Call(Clipboard)
        Else
            composeText := Clipboard
	runStage++
	Critical Off
    }
return

GetExePath(exename) {
    ; does not work: Process Exist, %exename%
    ; does not work: id := ErrorLevel

    ;from AutoHotkey help
    ; Example #4: Retrieves a list of running processes via DllCall then shows them in a MsgBox.
    s := 4096  ; size of buffers and arrays (4 KB)

    Process, Exist  ; sets ErrorLevel to the PID of this running script
    ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
    h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
    ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
    DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
    VarSetCapacity(ti, 16, 0)  ; structure of privileges
    NumPut(1, ti, 0, "UInt")  ; one entry in the privileges array...
    ; Retrieves the locally unique identifier of the debug privilege:
    DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
    NumPut(luid, ti, 4, "Int64")
    NumPut(2, ti, 12, "UInt")  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
    ; Update the privileges of this process with the new access token:
    r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
    DllCall("CloseHandle", "Ptr", t)  ; close this access token handle to save memory
    DllCall("CloseHandle", "Ptr", h)  ; close this process handle to save memory

    hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the library
    s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
    c := 0  ; counter for process idendifiers
    DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
    Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
    {
       id := NumGet(a, A_Index * 4, "UInt")
       ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
       h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
       if !h
	  continue
       VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
;       e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
;       if !e    ; fall-back method for 64-bit processes when in 32-bit mode:
	e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	DllCall("CloseHandle", "Ptr", h)  ; close process handle to save memory
	if (n && e) { ; if image is not null:
	    SplitPath n, nn, nd
	    If (nn=exename) {
		break
	    } Else {
		n=
	    }
	}
    }
    If (n) {
	DllCall("FreeLibrary", "Ptr", hModule)  ; unload the library to free memory
	if (n && e) { ; if image is not null:
	    replacePathTextFrom := "\Device\"
	    If (SubStr(nd, 1, StrLen(replacePathTextFrom)) == replacePathTextFrom)
		nd := "\\?\" . SubStr(nd, StrLen(replacePathTextFrom)+1)
	    
	    ; https://github.com/inspirer/history/blob/master/jy/win32pe/h/windows.h
	    GENERIC_READ			:= 0x80000000
	    FILE_SHARE_READ			:= 0x00000001
	    FILE_SHARE_WRITE		:= 0x00000002
	    FILE_SHARE_DELETE		:= 0x00000004
	    OPEN_EXISTING 			:= 3
	    FILE_FLAG_BACKUP_SEMANTICS	:= 0x02000000
	    INVALID_HANDLE_VALUE 		:= -1
	    
	    VOLUME_NAME_DOS			:= 0
	    
	    ;HANDLE WINAPI CreateFile(
	    ;  _In_     LPCTSTR               lpFileName,
	    ;  _In_     DWORD                 dwDesiredAccess,
	    ;  _In_     DWORD                 dwShareMode,
	    ;  _In_opt_ LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	    ;  _In_     DWORD                 dwCreationDisposition,
	    ;  _In_     DWORD                 dwFlagsAndAttributes,
	    ;  _In_opt_ HANDLE                hTemplateFile
	    ;);
	    
	    hFile := DllCall("CreateFileW", "Str", nd, "UInt", GENERIC_READ, "UInt", FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, "UInt", 0, "UInt", OPEN_EXISTING, "UInt", FILE_FLAG_BACKUP_SEMANTICS, "UInt", 0, "Ptr")
	    if (hFile == INVALID_HANDLE_VALUE) 
	    {
		MsgBox % "CreateFile Error: " . A_LastError
		return
	    }
	    
	    lpszFilePathSize := VarSetCapacity(lpszFilePath, 65536, 0)
	    
	    dw := DllCall("GetFinalPathNameByHandleW", "Ptr", hFile, "Str", lpszFilePath, "UInt", lpszFilePathSize - 1, "UInt", VOLUME_NAME_DOS, "UInt")

	    if (dw == 0)
	    {
		MsgBox % "GetFPNBYH: " . A_LastError
		return
	    }
	    else if (dw >= lpszFilePathSize)
	    {
		MsgBox % "GetFPNBYH: output requires " . dw . " characters"
		return
	    }

	    return lpszFilePath . "\" . nn
	}
    } Else {
	return
    }
}

#include *i <CutTrelloURLs>
