#NoEnv

addr=WaitForSubnet(IMVPNSubnets())

FileAppend % addr, *, CP1
If (cmdl := ParseScriptCommandLine())
    Run %cmdl%

ExitApp 0

IMVPNSubnets() {
    ; see https://wiki.intermedia.net/x/FZA-Bg (https://wiki.intermedia.net/display/NETENG/Corporate+VPN+subnets)
    prefixes_txt =
    (
        ACSPB	10.9.18.0/23
        ACLO	10.32.18.0/24
        ACVA	10.216.18.0/24
        ACCO	10.232.18.0/24
        ACCA	10.248.18.0/24
        ACWA	172.16.18.0/24
        ACSPB	10.8.18.0/23
        10.9.218.0/23
        ACLO	10.32.218.0/24
        ACVA	10.217.218.0/24
        ACCO	10.232.218.0/24
        ACCA	10.248.218.0/24
        ACWA	172.16.218.0/24
    )


    subnets := []
    Loop Parse, prefixes_txt, `n, `r
    {
        If (RegexMatch(A_LoopField, "((?:\d+\.){3}\d+)/(\d+)", m)) {
            ; m: full match
            ; m1: ip
            ; m2: mask
            subnets.Push([m1, m2])
        }
    }
    return subnets
}

WaitForSubnet(subnets) {
    local
    Loop
    {
        For i, addr in JEE_SysGetIPAddresses()
            For _, subnet in subnets
                If (IPAddressIsInSubnet(addr, subnet[1], subnet[2]))
                    return addr
        
        Sleep 1000
    }
}

IPAddressIsInSubnet(addr, prefix, mask) {
    local
    static lastAddr, lastPrefix, lastMask
         , addrParts, prefixParts, maskParts
         
    if (lastAddr != addr)
        lastAddr := addr, addrParts := StrSplit(addr, ".")
    if (lastPrefix != prefix)
        lastPrefix := prefix, prefixParts := StrSplit(prefix, ".")
    if (lastMask != mask) {
        lastMask := mask
        if (mask ~= "(\d+\.){3}\d+") {
            maskParts := StrSplit(mask, ".")
        } else {
            maskParts := [0,0,0,0]
            Loop 4
            {
                if (mask < 8) {
                    maskParts[A_Index] := (255 << mask) & 255
                    ; If (addr == "10.32.218.57" && prefix == "10.32.218.0")
                    ;     MsgBox % mask "`n" ObjectToText(maskParts)
                    break
                }
                maskParts[A_Index] := 255
                mask -= 8
            } Until !mask
        }
    }

    
;    Loop 4
;        MsgBox % addr "`n" prefix "`n" mask "`n" (addrParts[A_Index] & maskParts[A_Index] != prefixParts[A_Index] & maskParts[A_Index]) "`n" addrParts[A_Index] "&" maskParts[A_Index] "!=" prefixParts[A_Index] "&" maskParts[A_Index]

    Loop 4
        If (addrParts[A_Index] & maskParts[A_Index] != prefixParts[A_Index] & maskParts[A_Index])
            return false
    return true
}

;GetLocalIPs() {
;    local
;    adaptors := {}
;    ips := {}
;    objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
;    colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter")._NewEnum
;    While (colItems[objItem])
;        adaptors[objItem.InterfaceIndex] := objItem.NetConnectionID
;    For index, name in adaptors {
;        colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE InterfaceIndex = '" index "'")._NewEnum
;        While colItems[objItem] {
;            If (objItem.IPAddress[0])
;                ips[objItem.IPAddress[0]] := name
;        }
;    }
;    Return ips
;}

;==================================================

;gethostbyname macro | Microsoft Docs
;https://docs.microsoft.com/en-us/windows/desktop/api/wsipv6ok/nf-wsipv6ok-gethostbyname
;hostent | Microsoft Docs
;https://docs.microsoft.com/en-gb/windows/desktop/api/winsock/ns-winsock-hostent

JEE_SysGetIPAddresses() {
	local
	oArray := []
	;IP_ADDRESS_SIZE := 32
	VarSetCapacity(WSADATA, A_PtrSize=8?408:400, 0)
	if DllCall("ws2_32\WSAStartup", UShort,0x101, Ptr,&WSADATA)
		return
	VarSetCapacity(vHostName, 256, 0)
	DllCall("ws2_32\gethostname", Ptr,&vHostName, Int,256)
	;MsgBox, % StrGet(&vHostName, "CP0")
	if ((pHOSTENT := DllCall("ws2_32\gethostbyname", Ptr,&vHostName, "Cdecl Ptr")) != 0)
	{
		;vSize := NumGet(pHOSTENT+(A_PtrSize=8?18:10), "Short") ;h_length
		ppHAddrList := NumGet(pHOSTENT+(A_PtrSize=8?24:12)) ;**h_addr_list
		Loop 1000
		{
			vOffset := (A_Index-1)*A_PtrSize
			if !(pIP := NumGet(ppHAddrList+vOffset))
				break
			vIPAddress := ""
			Loop 4
				vIPAddress .= NumGet(pIP+0, A_Index-1, "UChar") "."
			vIPAddress := SubStr(vIPAddress, 1, -1)
			oArray.Push(vIPAddress)
		}
	}
	DllCall("ws2_32\WSACleanup")
	return oArray
}

;==================================================
