;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

WinHttpRequest(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef moreHeaders:=0, ByRef proxy:="") {
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
    For name, value in moreHeaders
        WebRequest.SetRequestHeader(name, value)
    ;WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy)
	WebRequest.SetProxy(2,proxy)
    
    Try {
	WebRequest.Send(POSTDATA)
	resp := {status: WebRequest.Status, headers: WebRequest.getAllResponseHeaders, responseText: WebRequest.responseText}
	WebRequest := ""
	
	If (IsObject(debug)) {
	    debug.Headers := resp.headers
	    debug.Status := resp.status	;can be 200, 404 etc., including proxy responses
	    
	    If (IsFunc(debug.cbStatus))
                Func(debug.cbStatus).Call( "`nStatus: " debug.Status "`n"
                                         . "Headers: " debug.Headers "`n"
                                         . resp.responseText "`n")
	}

	If (IsObject(rv_response)) {
	    rv_response := resp
	    return resp.Status >= 200 && resp.Status < 300
	} Else If (IsByRef(rv_response)) {
            rv_response := resp.responseText
	}
        return resp.status
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
