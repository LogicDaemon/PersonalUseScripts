;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

HTTPReq(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef headers:="") {
    local
    If (method = "POST") {
        If (!IsObject(headers))
            headers := {}
        If (!headers.HasKey("Content-Type"))
            headers["Content-Type"] := "application/x-www-form-urlencoded"
    }
    ;ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef headers:=0
    For _, func in ["XMLHTTP_Request", "WinHTTPReqWithProxies"] {
        Try {
            rv := Func(func).Call(method, URL, POSTDATA, rv_response, headers)
            If (IsObject(rv_response)) {
                If (rv.status)
                    Return rv
                Continue
            }
            ; otherwise, rv is a status code
            If (rv)
                Return rv
        }
    }
    Return rv
}

WinHTTPReqWithProxies(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef rv_response:=0, ByRef headers:=0, ByRef TryProxies := "") {
    local
    static proxies := ""
    ;URLprotoInURL := RegexMatch(URL, "([^:]{3,6})://", URLproto)

    If (!IsObject(proxies)) {
        proxies := {}
        If (IsObject(TryProxies)) {
            HTTPReq_PushMissingItems(proxies, TryProxies)
        } Else If (TryProxies) {
            Loop Parse, TryProxies, `n`r`,
                HTTPReq_PushMissingItems(proxies, [A_LoopField])
        }

        For i, v in ["http_proxy", "https_proxy"] {
            EnvGet env_proxy, %v%
            If (env_proxy)
                HTTPReq_PushMissingItems(proxies, env_proxy)
        }
        HTTPReq_PushMissingItems(proxies, [ ""
            , cuProxy := HTTPReq_ReadProxy("HKEY_CURRENT_USER")
            , lmProxy := HTTPReq_ReadProxy("HKEY_LOCAL_MACHINE")
            ; Очень странно: в Windows 7 префикс протокола ("https://") нужен для отправки через HTTPS, в Windows 10 – наоборот мешает :(
            , "https://" cuProxy
            , "http://" cuProxy
            , "https://" lmProxy
            , "http://" lmProxy ] )
    }

    For i,proxy in proxies
        Try {
        res := WinHttpRequest(method, URL, POSTDATA, rv_response, headers, proxy)
        If (res > 0 && res < 400)
            Return res
    }
    Return ""
}

HTTPReq_PushMissingItems(ByRef listToAppendTo, listToAppendFrom, ByRef newSetOfAllItems := 0) {
    local
    static setOfAllItems := ""
    If (IsByRef(newSetOfAllItems))
        setOfAllItems := newSetOfAllItems
    If (!IsObject(setOfAllItems))
        For i, v in listToAppendTo
            setOfAllItems[v] := ""
    For i, v in listToAppendFrom
        If (!setOfAllItems.HasKey(v))
            listToAppendTo.Push(v), setOfAllItems[v] := ""
}

HTTPReq_ReadProxy(ProxySettingsRegRoot) {
    local
    static ProxySettingsIEKey:="Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    Try {
        RegRead ProxyEnable, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyEnable
        If (ProxyEnable) {
            RegRead ProxyServer, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyServer
            return ProxyServer
        }
    }
}

#include %A_LineFile%\..\XMLHTTP_Request.ahk
#include %A_LineFile%\..\WinHttpRequest.ahk
