;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

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

#Warn Unreachable, Off
If (A_LineFile==A_ScriptFullPath) {
    global debug := {}
    Try {
        FileAppend % GetURL(A_Args*), *, CP1
        ExitApp 0
    }
    ExitApp 1
}

#include %A_LineFile%\..\HTTPReq.ahk
