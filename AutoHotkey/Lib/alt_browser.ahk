;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

If (!FileExist(A_ScriptDir "\alt_browser." A_COMPUTERNAME ".ahk")) {
    FileSelectFile browserPath, 3, ; 3 = 1: File Must Exist + 2: Path Must Exist
    If ErrorLevel
        ExitApp
    RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    If (hostname != A_COMPUTERNAME) ; A_COMPUTERNAME is always uppercase, but might also be shortened if the hostname is too long
        hostname = A_COMPUTERNAME
    FileAppend,
    (LTrim RTrim0
    #NoEnv
    FileEncoding UTF-8

    Run `% """%browserPath%"" " ParseScriptCommandLine()
    ExitApp

    #include <ParseScriptCommandLine>
    
    ), %A_ScriptDir%\alt_browser.%hostname%.ahk, UTF-8
    Run "%A_ScriptDir%\alt_browser.%hostname%.ahk"
    ExitApp
}

#include *i %A_ScriptDir%\alt_browser.%A_COMPUTERNAME%.ahk

GetHostnameDomain() {
    local ; Force-local mode
    hostname := Cached_GetTcpipParameters("Hostname")
    , domain := Cached_GetTcpipParameters("Domain")

    If (!domain || domain=="office0.mobilmir")
	return hostname
    Else
	return hostname "." Domain
}

Cached_GetTcpipParameters(prmName) {
    local ; Force-local mode
    static cache := {}
    
    If (cache.HasKey(prmName)) {
	val := cache[prmName]
    } Else {
	RegRead val, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, %prmName%
	cache[prmName] := val
    }
    
    return val
}
