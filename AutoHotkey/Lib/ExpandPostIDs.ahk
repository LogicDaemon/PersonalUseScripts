﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ExpandPostIDs(ByRef query) {
    local ; Force-local mode
    ; query is { [idFuncName: "prefix" [, idFuncName: "prefix" [, …]]] }
    ; use "" in place of idFuncName to specify values splitter in the string
    ; otherwise, idFuncName is expanded with ExpandIDFunc
    
    splitter := " "
    foundKeys := 0
    Loop 2
    {
	If (A_Index = 2) ; second loop only happens if object was empty, pre-fill it then
	    query := {"": " ", CutTrelloCardURL: -2, TrelloCardName: -1, Rnd4Hex: "rand_id:", A_Now: ""}
	For i in query {
	    foundKeys := 1
	    break
	}
    } Until foundKeys
    
    numberedPrefixesList := ""
    numberedPrefixesFuncs := []
    UnnumberedQueriedFuncs := {}
    For idFunc, txtPrefix in query {
	If (idFunc=="") {
	    splitter := txtPrefix
	} Else {
	    If txtPrefix is integer
	    {
		If (!IsObject(numberedPrefixesFuncs[txtPrefix])) {
		    numberedPrefixesList .= txtPrefix "`n"
		    numberedPrefixesFuncs[txtPrefix] := Object()
		}
		numberedPrefixesFuncs[txtPrefix][idFunc] := ExpandIDFunc(idFunc)
	    } Else {
		UnnumberedQueriedFuncs[idFunc] := ExpandIDFunc(idFunc)
	    }
	}
    }
    If (!IsObject(numberedPrefixesFuncs[0]))
	numberedPrefixesList .= "0"
    Sort N, numberedPrefixesList
    
    iov := 0
    Loop Parse, numberedPrefixesList, `n
    {
	For idFunc, v in numberedPrefixesFuncs[A_LoopField]
	    retval .= splitter . v
	If (A_LoopField == "0")
	    For idFunc, v in UnnumberedQueriedFuncs
		retval .= splitter . query[idFunc] . v
    }
    
    return SubStr(retval, 1 + StrLen(splitter))
}

ExpandIDFunc(idFunc) {
    local ; Force-local mode
    ;	  idFunc are keys from funcIDs or quoted func names,
    ;     prefix is any text or number for ordering (non-numbers text considered to be 0)
    static funcIDs := { TrelloUrl:	Func("GetValueFromTrelloIdObject").Bind("url")
		      , TrelloCardName: Func("GetValueFromTrelloIdObject").Bind("name")
		      , TrelloID:	Func("GetValueFromTrelloIdObject").Bind("id")
		      , TrelloList:	Func("GetValueFromTrelloIdObject").Bind("List")
		      , CutTrelloCardURL: Func("CutTrelloCardURLFromTrelloIdObject")
		      , Rnd4Hex:	Func("PostID_Rnd4Hex")
		      , A_Now:		Func("PostID_A_Now")
		      , oldHostname:	Func("Cached_GetTcpipParameters").Bind("NV Hostname")
		      , Hostname:	Func("Cached_GetTcpipParameters").Bind("Hostname")
		      , Domain:		Func("Cached_GetTcpipParameters").Bind("Domain")
		      , HostnameDomain:	Func("GetHostnameDomain")
		      , ipify:		Func("getURL").Bind("https://api.ipify.org/") }
    
    If (idFunc) {
	If (funcIDs.HasKey(idFunc))
	    return Trim(funcIDs[idFunc].Call(), " `r`n`t")
	Else
	    return Func(idFunc).Call()
    }
}

CutTrelloCardURLFromTrelloIdObject() {
    return CutTrelloCardURL(Cache_TrelloIdFromTxt().url)
}

GetValueFromTrelloIdObject(valName) {
    return Cache_TrelloIdFromTxt()[valName]
}

Cache_TrelloIdFromTxt() {
    local ; Force-local mode
    static trelloIdObj := ""
    If (!IsObject(trelloIdObj))
	trelloIdObj := ReadTrelloIdFromTxt()
    return trelloIdObj
}

PostID_Rnd4Hex() {
    local ; Force-local mode
    Random rnd, 0, 0xFFFF
    return Format("{:04x}", rnd)
}

PostID_A_Now() {
    return A_Now
}

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

#include %A_LineFile%\..\ReadTrelloIdFromTxt.ahk
#include %A_LineFile%\..\GetURL.ahk
