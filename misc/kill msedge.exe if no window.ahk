﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If WinExist("ahk_exe msedge.exe")
    Exit

; First try to Process Close all them
For pid, name in ProcessList("msedge.exe")
    Process Close, %pid%

; Then TASKKILL if anything remains
While True {
    Process Exist, msedge.exe
    If (!ErrorLevel)
        Break
    Run taskkill.exe /f /im msedge.exe,,Hide
}

Exit


ProcessList(nameFilter := "", unloadPsapi := True) {
    global PsapiDllhModule
    If (nameFilter)
        filterLen := -StrLen(nameFilter), nameFilter := "\" nameFilter
    ; example from ahk help
    out := {}
    d := "  |  "  ; string separator
    s := 4096  ; size of buffers and arrays (4 KB)

    Process, Exist  ; Sets ErrorLevel to the PID of this running script.
    ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400):
    h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
    ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32):
    DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
    VarSetCapacity(ti, 16, 0)  ; structure of privileges
    NumPut(1, ti, 0, "UInt")  ; one entry in the privileges array...
    ; Retrieves the locally unique identifier of the debug privilege:
    DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
    NumPut(luid, ti, 4, "Int64")
    NumPut(2, ti, 12, "UInt")  ; Enable this privilege: SE_PRIVILEGE_ENABLED = 2
    ; Update the privileges of this process with the new access token:
    r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
    DllCall("CloseHandle", "Ptr", t)  ; Close this access token handle to save memory.
    DllCall("CloseHandle", "Ptr", h)  ; Close this process handle to save memory.
    
    If (!PsapiDllhModule)
        PsapiDllhModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; Increase performance by preloading the library.
    s := VarSetCapacity(a, s)  ; An array that receives the list of process identifiers:
    c := 0  ; counter for process idendifiers
    DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
    Loop, % r // 4  ; Parse array for identifiers as DWORDs (32 bits):
    {
        id := NumGet(a, A_Index * 4, "UInt")
        ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
        h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
        if !h
            continue
        VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
        e := DllCall("Psapi.dll\GetModuleFileName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
        if !e    ; fall-back method for 64-bit processes when in 32-bit mode:
            e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
        DllCall("CloseHandle", "Ptr", h)  ; close process handle to save memory
        if (n && e && (nameFilter=="" || SubStr(n,filterLen) = nameFilter))  ; if image is not null add to list:
            out[id] := n
    }
    If (unloadPsapi) {
        DllCall("FreeLibrary", "Ptr", PsapiDllhModule)  ; Unload the library to free memory.
        PsapiDllhModule := 0
    }
    return out
}
