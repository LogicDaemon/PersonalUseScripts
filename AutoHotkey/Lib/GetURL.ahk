;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

GetURL(ByRef URL, retries := 3, delay := 3000) {
    local
    exc := ""
    Loop
    {
        Try {
            st := HTTPReq("GET", URL,, resp := "")
        } Catch exc {
            Continue
        }
        If (st < 300) ; up to 300 are OK
            Return resp
        If (st >= 500 || st == 408 || st == 409 || st == 423 || st == 424) { ; repeat on server errors
            Sleep delay
            Continue
        }
        If (st >= 400)
            Break ; errors 400…500 are fatal
        ; 300-399 are redirects, normally never returned by HTTPReq
        If (RegExMatch(headers, "^Location: (.+)", newURL)) {
            URL := newURL1
            retries++ ; do not count redirects as retries
            Continue
        }
    } Until A_Index > retries
    If (IsObject(exc))
        Throw exc
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
