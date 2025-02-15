﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv

PostGoogleForm(URL, ByRef kv, tries:=20, retryDelay:=20000) {
    If (!IsObject(kv))
        Throw Exception("Keys and Values should be passed as an object", A_ThisFunc, kv)

    If (!(URL ~= "/formResponse$")) {
        If (!RegexReplace(URL, "/(edit|viewform)([\?#].*)?", "/formResponse"))
            URL .= (SubStr(URL, 0) == "/" ? "" : "/" ) . "/formResponse"
    }
    ;url looks like: "https://docs.google.com/a/mobilmir.ru/forms/d/e/***/formResponse"
    ;expected post data format: "entry.615879702=test&entry.67493091=dept&entry.1721746842=ver&fvv=1&draftResponse=%5B%2C%2C%227974343457504139194%22%5D%0D%0A&pageHistory=0&fbzx=7974343457504139194",

    For k,v in kv
        POSTDATA .= k . "=" . UriEncode(v) . "&"
    POSTDATA := SubStr(POSTDATA,1,-1)

    Loop
    {
        resp := HTTPReq("POST", URL, POSTDATA)
        If (resp.status < 300)
            Return True
        Sleep retryDelay
    } Until --tries
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    FileEncoding UTF-8
    kv := Object()
    debug := Object()
    Loop %0%
    {
        arg:=%A_Index%
        If (URL) {
            If (!foundPos := InStr(arg, "="))
                Throw Exception("Arg """ arg """ is must be in format ""key=value""", "([^=]+)=(.+)", arg)
            kv[SubStr(arg, 1, foundPos-1)] := SubStr(arg, foundPos+1)
        } Else {
            URL:=arg
        }
    }
    ExitApp !PostGoogleForm(URL,kv)
}

#include %A_LineFile%\..\HTTPReq.ahk
#include %A_LineFile%\..\URIEncodeDecode.ahk
