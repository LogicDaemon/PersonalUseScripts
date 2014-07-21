﻿;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
SendMode InputThenPlay

cmdlArgs := ParseCommandLine()
EnvGet LocalAppData, LOCALAPPDATA

pathSUMoDist := FirstExisting(           "d:\Distributives\Soft com freeware\Trackers Updaters Catalogs\SUMo\sumo.7z"
                             ,  "\\localhost\Distributives\Soft com freeware\Trackers Updaters Catalogs\SUMo\sumo.7z"
                             , "\\miwifi.com\Distributives\Soft com freeware\Trackers Updaters Catalogs\SUMo\sumo.7z")
If (!pathSUMoDist)
    Throw Exception("SUMO Distributive path not found")

EnvGet LocalAppData,LOCALAPPDATA
SUMoInstPath := FirstExisting(LocalAppData . "\Programs\SUMo", LocalAppData . "\Programs\SUMo")
If (!SUMoInstPath)
    SUMoInstPath := LocalAppData . "\Programs\SUMo"

RunWait "%A_ProgramFiles%\7-Zip\7zG.exe" x -aoa -o"%SUMoInstPath%\.." "%pathSUMoDist%", %A_Temp%, Min
Run "%SUMoInstPath%\SUMo.exe" %params%, %SUMoInstPath%

;While WinExist("SUMo ahk_class TMessageForm")
;{
;    WinWaitActive SUMo ahk_class TMessageForm
;    ControlSend,, {Enter}
;}

FirstExisting(params*) {
    for index,param in params
        IfExist %param%
	    return param
    return ""
}

ParseCommandLine() {
    CommandLine := DllCall( "GetCommandLine", "Str" )
    ; ["]%A_AhkPath%["] [args] ["][%A_ScriptDir%\]%A_ScriptName%["] [args]
    
    inQuote := 0
    currFragmentEnd := 1
    Loop Parse, CommandLine, %A_Space%%A_Tab%
    {
	If (!inQuote) {
	    currArgStart := currFragmentEnd
	    argNo++
	}
	currFragmentEnd += StrLen(A_LoopField)+1
	
	outerLoopField := A_LoopField
	Loop Parse, A_LoopField, "
	{
	    If (A_Index-1) ; for «"string"», first loop field is empty. If string is at EOL, last too.
		inQuote := !inQuote
	}

	If (inQuote) { ; this substring is part of quote (starting at currArgStart)
	    continue
	}
	; Else := If(!inQuote) { ; quote is just over or not started
	currArg := Trim(SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart))

	If (realScriptPath) { ; script name found in cmdline, script args following
	    ; on first entrance, %1% must be = Trim(currArg; """")
;	    If (currArg="/KillOnExit") {
;		skipChars := currFragmentEnd ; next char after this argument
;	    	global forceExit :=0
;		OnExit("KillUT")
;	    }
	    break ; break in any case, because only first argument after script name needs to be checked
	} Else {
	    If (argNo==1) {
		;First arg is always autohotkey-exe (path optional, for example, if started via cmdline: try «cmd /c ahk.exe script.ahk»; even extension may not be there. Path can be partial, repeating ahk-name: «./ahk.exe/ahk script/ahk/script.ahk»).
;		RealAhkPath := currArg
	    } Else If (InStr(currArg, A_ScriptName)) {
		realScriptPath := currArg
		skipChars := currFragmentEnd ; next char after real script name
	    }
	}
    }
    
    return SubStr(CommandLine, skipChars)
}
