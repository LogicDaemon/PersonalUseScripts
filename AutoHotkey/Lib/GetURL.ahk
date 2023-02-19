;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

GetURL(ByRef URL, tries := 20, delay := 3000) {
    local
    While (A_Index <= tries) {
        st := HTTPReq("GET", URL,, resp := "")
	If (st < 500) { ; only repeat on server errors (≥ 500)
            If (st < 400)
                return resp
            break ; errors 400…500 are fatal
        }
        sleep delay
    }
    Throw Exception("Error downloading URL", A_ThisFunc, st)
}

If (A_LineFile==A_ScriptFullPath) {
    global debug := {}
    Try {
        FileAppend % GetURL(A_Args*), *, CP1
        ExitApp 0
    }
    ExitApp 1
}

#include %A_LineFile%\..\HTTPReq.ahk
