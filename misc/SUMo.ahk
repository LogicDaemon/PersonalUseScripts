﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
SendMode InputThenPlay

cmdlArgs := ParseCommandLine()
EnvGet LocalAppData, LOCALAPPDATA

pathSUMoDist := Find_Distributives_subpath("Soft com freeware\Trackers Updaters Catalogs\SUMo\sumo.7z")
SplitPath pathSUMoDist,, dirSUMoDist

EnvGet LocalAppData,LOCALAPPDATA
SUMoInstPath := FirstExisting(LocalAppData . "\Programs\SUMo", LocalAppData . "\Programs\SUMo")
If (!SUMoInstPath)
    SUMoInstPath := LocalAppData . "\Programs\SUMo"

RunWait %comspec% /C "%dirSUMoDist%\.Distributives_Update_Run.Office.cmd", %dirSUMoDist%, Min
RunWait "%A_ProgramFiles%\7-Zip\7zG.exe" x -aoa -o"%SUMoInstPath%\.." "%pathSUMoDist%", %A_Temp%, Min
Run "%SUMoInstPath%\SUMo.exe" %params%, %SUMoInstPath%

;While WinExist("SUMo ahk_class TMessageForm")
;{
;    WinWaitActive SUMo ahk_class TMessageForm
;    ControlSend,, {Enter}
;}
Exit

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
