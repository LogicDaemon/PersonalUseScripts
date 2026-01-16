Process_mode_background_begin(pid := 0) {
    Local
    If (!pid)
        pid := DllCall("GetCurrentProcessId")
    DllCall("SetPriorityClass", "UInt", pid, "UInt", 0x00100000) ; PROCESS_MODE_BACKGROUND_BEGIN=0x00100000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
}

Process_mode_background_end(pid := 0) {
    Local
    If (!pid)
        pid := DllCall("GetCurrentProcessId")
    DllCall("SetPriorityClass", "UInt", pid, "UInt", 0x00200000) ; PROCESS_MODE_BACKGROUND_END=0x00200000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
}
