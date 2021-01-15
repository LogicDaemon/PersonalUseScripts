;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

HTTPReq(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef reqmoreHeaders:=0) {
    local
    If (method = "POST") {
        If (reqmoreHeaders==0) {
            moreHeaders := {"Content-Type": "application/x-www-form-urlencoded"}
        } Else If (IsObject(reqmoreHeaders)) {
            If (reqmoreHeaders.HasKey("Content-Type")) {
                moreHeaders := reqmoreHeaders
            } Else {
                moreHeaders := reqmoreHeaders.Clone()
                moreHeaders["Content-Type"] := "application/x-www-form-urlencoded"
            }
        }
    }
    ;ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0
    return XMLHTTP_Request(method, URL, POSTDATA, response, moreHeaders) || WinHTTPReqWithProxies(method, URL, POSTDATA, response, moreHeaders)
}

WinHTTPReqWithProxies(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0, ByRef TryProxies := "") {
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
        Try If (success := WinHttpRequest(method, URL, POSTDATA, response, moreHeaders, proxy))
            return success
    
    return 0
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
