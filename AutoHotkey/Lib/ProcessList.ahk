ProcessList_NameFilter(nameFilter, ByRef moduleName) {
    Return SubStr(moduleName, -StrLen(nameFilter)) = nameFilter
}

ProcessList_ReturnTrue(ByRef v) {
    Return True
}

; nameOrFilter:
;   an empty string to get all processes
;   a string to filter the process list by the name of the process
;   a function object to filter the process list by the name of the process
ProcessList(nameOrFilter := "", unloadPsapi := True) {
    local
    static PsapiDllhModule := 0
    If (nameOrFilter == "") {
        filter := Func("ProcessList_ReturnTrue")
    } Else If (IsFunc(nameOrFilter)) {
        filter := Func(nameOrFilter)
    } Else {
        filter := ProcessList_NameFilter.Bind("\" nameOrFilter)
    }
    out := {}

    ; based on an example from ahk help
    ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400):
    currentScriptHandle := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", DllCall("GetCurrentProcessId"), "Ptr")
    ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32):
    DllCall("Advapi32.dll\OpenProcessToken", "Ptr", currentScriptHandle, "UInt", 32, "PtrP", t := 0)
    VarSetCapacity(ti := "", 16, 0) ; structure of privileges
    NumPut(1, ti, 0, "UInt") ; one entry in the privileges array...
    ; Retrieves the locally unique identifier of the debug privilege:
    DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid := 0)
    NumPut(luid, ti, 4, "Int64")
    NumPut(2, ti, 12, "UInt") ; Enable this privilege: SE_PRIVILEGE_ENABLED = 2
    ; Update the privileges of this process with the new access token:
    result := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
    DllCall("CloseHandle", "Ptr", t) ; Close this access token handle to save memory
    DllCall("CloseHandle", "Ptr", currentScriptHandle) ; Close this process handle to save memory

    If (!PsapiDllhModule)
        PsapiDllhModule := DllCall("LoadLibrary", "Str", "Psapi.dll") ; Increase performance by preloading the library.
    reqBufferSize := 4096
    Loop ; Until buffer is large enough to hold all process identifiers
    {
        effectiveBufferSize := VarSetCapacity(pidBuffer, reqBufferSize) ; An array that receives the list of process identifiers:
        result := DllCall("Psapi.dll\EnumProcesses", "Ptr", &pidBuffer, "UInt", effectiveBufferSize, "UIntP", cbReceived := 0)
        If (!result)
            Throw Exception("EnumProcesses failed",, A_LastError)
        If (cbReceived == effectiveBufferSize) ; buffer too small
            reqBufferSize *= 2
        Else
            Break
    }

    Loop, % cbReceived // 4 ; Parse array for identifiers as DWORDs (32 bits)
    {
        id := NumGet(pidBuffer, A_Index * 4, "UInt")
        ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
        procHandle := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
        If (!procHandle)
            Continue
        reqBufferSize := 4096
        Loop ; Until buffer is large enough to hold the base name of the module
        {
            
            bufferSize := VarSetCapacity(moduleName, reqBufferSize, 0) ; a buffer that receives the base name of the module
            nSize := A_IsUnicode ? bufferSize//2 : bufferSize
            rSize := DllCall("Psapi.dll\GetModuleFileName", "Ptr", procHandle, "Ptr", 0, "Str", moduleName, "UInt", nSize)
            If (!rSize) ; fall-back method for 64-bit processes when in 32-bit mode
                rSize := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", procHandle, "Str", moduleName, "UInt", nSize)
            If (rSize == nSize) ; buffer too small
                reqBufferSize *= 2
            Else
                Break
        }
        DllCall("CloseHandle", "Ptr", procHandle) ; close process handle to save memory
        If (rSize && filter.Call(moduleName)) ; if image is not null add to list
            out[id] := moduleName
    }
    If (unloadPsapi) {
        DllCall("FreeLibrary", "Ptr", PsapiDllhModule) ; Unload the library to free memory
        PsapiDllhModule := 0
    }
    return out
}

; #Warn
; MsgBox % ObjectToText(ProcessList())
