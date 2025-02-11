;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

WinHttpRequest(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef headers:=0, ByRef proxy:="") {
    ; if rv_response is ByRef, it will be filled with response data and the request will return status code
    ; otherwise, XMLHTTP_Request will return the response data
    local
    #Warn UseUnsetGlobal, Off
    global debug
    static WinHttpRequestObjectName := ""
    If (WinHttpRequestObjectName) {
        WebRequest := ComObjCreate(WinHttpRequestObjectName)
    } Else {
        For i, WinHttpRequestObjectName in ["WinHttp.WinHttpRequest.5.1", "WinHttp.WinHttpRequest"] {
            Try WebRequest := ComObjCreate(WinHttpRequestObjectName)
            If (IsObject(WebRequest))
                break
        }
    }
    WebRequest.Open(method, URL, false)
    For name, value in headers
        WebRequest.SetRequestHeader(name, value)
    ;WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy)
        WebRequest.SetProxy(2,proxy)

    Try {
        WebRequest.Send(POSTDATA)
        resp := {status: WebRequest.Status, headers: WebRequest.getAllResponseHeaders, text: WebRequest.responseText}
        WebRequest := ""

        If (IsObject(debug)) {
            debug.Headers := resp.headers
            debug.Status := resp.status	;can be 200, 404 etc., including proxy responses

            If (IsFunc(debug.cbStatus))
                Func(debug.cbStatus).Call( "`nStatus: " debug.Status "`n"
                    . "Headers: " debug.Headers "`n"
                    . resp.responseText "`n")
        }

        If (IsByRef(rv_response)) {
            rv_response := resp
            return resp.status
        }
        return resp
    } catch e {
        If (IsObject(debug)) {
            debug.What := e.What
            debug.Message := e.Message
            debug.Extra := e.Extra
            If (IsFunc(debug.cbError))
                Func(debug.cbError).Call(e)
            Else
                Throw e
        }
    } Finally {
        WebRequest := ""
        If (IsObject(debug)) {
            ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
            ;static document
            ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
            ;Gui Show
            If (IsFunc(debug.cbStatus))
                Func(debug.cbStatus).Call()
        }
    }
}
