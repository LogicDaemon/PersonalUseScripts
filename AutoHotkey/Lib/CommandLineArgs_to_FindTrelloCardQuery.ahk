﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

CommandLineArgs_to_FindTrelloCardQuery(ByRef options := "", query := "", ByRef othersw := "") {
    local ; Force-local mode
    If (!IsObject(query))
	query := Object()
    
    optionParams := options, args := ParseScriptCommandLine("""")
    Loop % args[""]-1
    {
	argv := args[A_Index]
	If (option) {
	    options[option] := argv, option := ""
	} Else If (parmName) {
	    parmValue := argv
	} Else {
            If (!argv)
                continue
	    If (SubStr(argv, 1, 1) == "/") {
		option := SubStr(argv, 2)
		If (!optionParams[option])
                    options[option] := "", option := ""
		continue
	    } Else {
		If (!colon := InStr(argv, ":")) {
                    If (IsByRef(othersw)) {
                        If(IsObject(othersw))
                            othersw[A_Index] := argv
                        Else
                            othersw .= argv " "
                    } Else
                        Throw Exception("Param name should end with a colon", A_LineFile ": " A_ThisFunc, argv)
                } Else {
                    parmName := Trim(SubStr(argv, 1, colon-1))
                    parmValue := Trim(SubStr(argv, colon+1)) ; if "", this arg is just a param name, next arg is parm value
                }
	    }
	}
	If (parmValue) { 
	    If (query.HasKey(parmName)) {
		If (!IsObject(query[parmName]))
		    query[parmName] := {query[parmName]: parmName "0"}
		query[parmName][parmValue] := parmName A_Index
	    } Else
		query[parmName] := parmValue
	    parmName=
	}
    }
    return query
}

#include %A_LineFile%\..\ParseScriptCommandLine.ahk
