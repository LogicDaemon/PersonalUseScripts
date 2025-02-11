;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

XMLHTTP_Post(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef headers:=0) {
    If (!IsObject(headers))
        headers := {}
    If (!headers.HasKey("Content-Type"))
        headers["Content-Type"] := "application/x-www-form-urlencoded"
    Return XMLHTTP_Request("POST", URL, POSTDATA, response, headers)
}

#include %A_LineFile%\..\XMLHTTP_Request.ahk

If (A_ScriptFullPath == A_LineFile) { ; this is a direct call, not inclusion
    tries:=20
    retryDelay:=1000
    Loop %0%
    {
        arg:=%A_Index%
        argFlag:=SubStr(arg,1,1)
        If (argFlag=="/" || argFlag=="-") {
            arg:=SubStr(arg,2)
            foundPos := RegexMatch(arg, "([^=]+)=(.+)", argkv)
            If (foundPos) {
                If (argkv1 = "tries") {
                    tries := argkv2
                } Else If (argkv1 = "retryDelay") {
                    retryDelay := argkv2
                } Else {
                    XMLHTTP_EchoWrongArg(arg)
                }
            } Else {
                If (arg="debug") {
                    debug := Object()
                    FileAppend Включен режим отладки`n, **
                } Else {
                    XMLHTTP_EchoWrongArg(arg)
                }
            }
        } Else If (!URL) {
            URL:=arg
        } Else If (!POSTDATA) {
            POSTDATA:=arg
        } Else {
            XMLHTTP_EchoWrongArg(arg)
        }
    }
    Loop %tries%
    {
        response := Object()
        If (XMLHTTP_PostForm(URL,POSTDATA, response))
            Exit 0
        sleep %retryDelay%
    }
    ExitApp response.status
}

XMLHTTP_EchoWrongArg(arg) {
    FileAppend Invalid command line argument: %arg%`n, **
}
