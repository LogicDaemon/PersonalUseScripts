IsResponding(wid, timeOut := 100) { ; wid = unique ID number of a window to check: WinGet, wid, ID, Calculator
    local ; Force-local mode
    ;https://autohotkey.com/board/topic/21656-not-responding-check-a-windows-status/
    ; /*
    ;  * SendMessageTimeout values
    ; 
    ; #define SMTO_NORMAL         0x0000
    ; #define SMTO_BLOCK          0x0001
    ; #define SMTO_ABORTIFHUNG    0x0002
    ; #if(WINVER >= 0x0500)
    ; #define SMTO_NOTIMEOUTIFNOTHUNG 0x0008
    ; #endif /* WINVER >= 0x0500 */
    ; #endif /* !NONCMESSAGES */
    ; 
    ; 
    ; SendMessageTimeout(
    ;     __in HWND hWnd,
    ;     __in UINT Msg,
    ;     __in WPARAM wParam,
    ;     __in LPARAM lParam,
    ;     __in UINT fuFlags,
    ;     __in UINT uTimeout,
    ;     __out_opt PDWORD_PTR lpdwResult);
    ;     */

    NR_temp =0 ; init
    ;TimeOut = 100 ; milliseconds to wait before deciding it is not responding - 100 ms seems reliable under 100% usage
    ; WM_NULL =0x0000
    ; SMTO_ABORTIFHUNG =0x0002
    return DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0000, "Int", 0, "Int", 0, "UInt", 0x0002, "UInt", TimeOut, "UInt *", NR_temp)
}
