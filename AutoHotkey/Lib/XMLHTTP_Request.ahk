;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

XMLHTTP_Request(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef moreHeaders:=0) {
    local
    global debug
    #Warn UseUnsetGlobal, Off
    If (IsObject(debug))
	debug.url := URL
	, debug.method := method
	, XMLHTTP_Request_DebugMsg(method " " URL . (POSTDATA ? " ← " POSTDATA : "")
                                   . ( moreHeaders ? "`n`tHeaders:`n" XMLHTTP_Request_ahk_ObjectToText(moreHeaders) : ""))
    xhr := XMLHTTP_Request_CreateXHRObject()
    ;xhr.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    xhr.open(method, URL, false)
    ;xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    
    #Warn UseUnsetLocal, Off
    For hName, hVal in moreHeaders
        xhr.setRequestHeader(hName, hVal)
    Try {
	xhr.send(POSTDATA)
	If (IsObject(debug))
	    For debugField, xhrField in {Headers: "getAllResponseHeaders", Response: "responseText", Status: "status"} ; status can be 200, 404 etc., including proxy responses
		debug[debugField] := xhr[xhrField]
	resp := {status: xhr.status, headers: xhr.getAllResponseHeaders, responseText: xhr.responseText}
	xhr := ""
	If (IsObject(rv_response)) {
            rv_response := resp
            return resp.Status >= 200 && resp.Status < 300
	} Else If (IsByRef(rv_response))
	    rv_response := resp.responseText
        return resp.status
    } catch e {
	If (IsObject(debug))
	    debug.e := e
	Throw e
    } Finally {
	xhr := ""
	If (IsObject(debug)) {
	    XMLHTTP_Request_DebugMsg(debug)
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	}
    }
}

XMLHTTP_Request_CreateXHRObject() {
    local
    global debug
    static useObjName:=""

    If (useObjName) {
	return ComObjCreate(useObjName)
    } Else {
	errLog=
	For i, objName in ["Msxml2.XMLHTTP", "Microsoft.XMLHTTP", "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0"] {
	    If (IsObject(debug))
		debug.XMLHTTPObjectName := objName, XMLHTTP_Request_DebugMsg("`tTrying to create object " objName "…")
		
	    xhr := ComObjCreate(objName) ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
	    If (IsObject(xhr)) {
		useObjName := objName
		If (IsObject(debug))
		    XMLHTTP_Request_DebugMsg("Done!")
		return xhr
	    } Else {
		errLog .= objName ": " A_LastError "`n"
	    }
	    If (IsObject(debug))
		XMLHTTP_Request_DebugMsg("nope")
	}
	If (!useObjName)
	    Throw Exception("Не удалось создать объект XMLHTTP", A_LineFile ":" A_ThisFunc, SubStr(errLog, 1, -1))
    }
}

XMLHTTP_Request_DebugMsg(ByRef text) {
    local
    static outMethod := -1, outf
    If (outMethod == -1) {
	For i, fname in [A_Temp "\" A_ScriptName ".debug." A_Now ".log", "**", "*"]
	    Try outf := FileOpen(fname, "w")
	Until IsObject(outf)
	outMethod := IsObject(outf)
    }
    
    If (outMethod)
	out.WriteLine((IsObject(text) ? XMLHTTP_Request_ahk_ObjectToText(text) : text))
    Else
	MsgBox % A_ScriptName ": " A_LineFile ": " A_ThisFunc "`n" (IsObject(text) ? XMLHTTP_Request_ahk_ObjectToText(text) : text)
}

XMLHTTP_Request_ahk_ObjectToText(obj) {
    local
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" XMLHTTP_Request_ahk_ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}
