#NoEnv
#SingleInstance Force

connSet := {}
connGuiList := ""
Loop Reg, HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions, K
{
    RegRead hostName, %A_LoopRegKey%, %A_LoopRegSubkey%\%A_LoopRegName%, HostName
    If (hostName) {
        connSet[A_LoopRegName] := ""
        connGuiList .= A_LoopRegName "|"
    }
}

Gui Add, ComboBox, w300 h400 Simple vselConnItem, %connGuiList%
Gui Add, Button, Default, OK
Gui Add, Button,, Cancel
Gui Show
return

ButtonOK:
    Gui Submit
    RegRead proxyMethod, HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions\%selConnItem%, ProxyMethod
    If (proxyMethod) {
        RegRead proxyHost, HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions\%selConnItem%, ProxyHost
        If (proxyHost == "127.0.0.1") {
            RegRead proxyPort, HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions\%selConnItem%, ProxyPort
            EnsureProxiesRunning(proxyPort)
        }
    }
    If (connSet.HasKey(selConnItem)) {
        connName := DecodePuttyConnName(selConnItem)
        Run putty.exe -load "%connName%"
    } Else {
        Run putty.exe %selConnItem%
    }
    WinWaitActive ahk_exe putty.exe
    Sleep 1000
    ToolTip
ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

EnsureProxiesRunning(port) {
    GroupAdd proxy1080, jnldev-va-2.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
    GroupAdd proxy1080, jnldev-wa-2.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
    GroupAdd proxy1080, jnldev-va-am-media.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
    GroupAdd proxy1081, cdn-jump.anymeeting.com - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
    
    Loop
    {
        portState := TCP_PortExist(port)
        If (portState > 1) {
            ToolTip port %port% is open (%portState%)
            return
        }
        If (WinExist("ahk_group proxy" port)) {
            ToolTip putty for proxying port %port% is running
            return
        }
        ToolTip Starting proxies...
        RunWait "%A_AhkPath%" "%A_ScriptDir%\intermedia_putty_jumpnets.ahk"
        WinWait ahk_group proxy%port%
        Sleep 1000
    }
}

DecodePuttyConnName(ByRef regName) {
    return StrReplace(regName, "%20", " ")
}

; from https://www.autohotkey.com/boards/viewtopic.php?p=368218#p368218
TCP_PortExist(port) {
	static hIPHLPAPI := DllCall("LoadLibrary", "str", "iphlpapi.dll", "ptr"), table := []
	VarSetCapacity(TBL, 4 + (s := (20 * 32)), 0)
	while (DllCall("iphlpapi\GetTcpTable", "ptr", &TBL, "uint*", s, "uint", 1) = 122)
		VarSetCapacity(TBL, 4 + s, 0)

	loop % NumGet(TBL, 0, "uint") {
		o := 4 + ((A_index - 1) * 20)
		, temp_port := (((ROW := NumGet(TBL, o+8,  "uint"))&0xff00)>>8) | ((ROW&0xff)<<8)
		, state := NumGet(TBL, o, "uint")
		if (temp_port = port)
			return state ; , DllCall("FreeLibrary", "ptr", hIPHLPAPI)
	}
	return 0 ; , DllCall("FreeLibrary", "ptr", hIPHLPAPI)
}

/* ===============================================================================================================================
References:
- https://msdn.microsoft.com/en-us/library/aa366026(v=vs.85).aspx    GetTcpTable function
- https://msdn.microsoft.com/en-us/library/aa366917(v=vs.85).aspx    MIB_TCPTABLE structure
- https://msdn.microsoft.com/en-us/library/aa366909(v=vs.85).aspx    MIB_TCPROW structure
State-Codes:
- CLOSED         1
- LISTEN         2
- SYN_SENT       3
- SYN_RCVD       4
- ESTAB          5
- FIN_WAIT1      6
- FIN_WAIT2      7
- CLOSE_WAIT     8
- CLOSING        9
- LAST_ACK      10
- TIME_WAIT     11
- DELETE_TCB    12
*/