;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

#NoEnv
#Persistent
#SingleInstance force

global exepath,exename,exedir,forceExit:=1
If (!exename) {
    If (!exepath) {
        If (!IsObject(cmdlArgs))
            cmdlArgs := GetScriptArgsParse(1)
        exepath := cmdlArgs[1], exeargs := cmdlArgs[2]
    }
    SplitPath exepath, exename, exedir
}

If (!exepath) {
    FileAppend path-to-executable not found in command line.`nUsage: "%A_AhkPath%" [ahk-args] "%A_ScriptFullPath%" [/KillOnExit] {path-to-executable} [args for executable]`n,**,CP1
    ExitApp -1
}

Loop {
    runAgain := 0
    Process Exist, %exename%
    oldexePID := ErrorLevel
    global exePID
    Run %exepath% %exeargs%,%exedir%,,exePID

    WinWait ahk_pid %exePID%,,5
    If (ErrorLevel) {
	exePID := oldexePID
	runAgain:=1
    }
   
    If (oldexePID)
	KillExeOnAhkExit()
    
    Sleep 10000

    If (runAgain)
	SecondRun++
} Until (SecondRun || !runAgain)

Process Exist, %exePID%
If (!ErrorLevel)
    Process Exist, %exename%
If (ErrorLevel)
    Process WaitClose, %ErrorLevel%

ExitApp

GetScriptArgsParse(parseArgsNum) {
    CommandLine := DllCall( "GetCommandLine", "Str" )
    ; ["]%A_AhkPath%["] [ahk-args] ["][%A_ScriptDir%\]%A_ScriptName%["] [/KillOnExit] [parseArgs*] [return-args-as-is]
    
    inQuote := 0
    currFragmentEnd := 1
    argNo := 0
    parseArgNo := 0
    If (parseArgsNum)
	parsedArgs := []
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
	    If (A_Index-1) ; for «"string"», first loop field is empty. If string at EOL, last too.
		inQuote := !inQuote
	}

	If (inQuote) { ; this substring is part of quote (starting at currArgStart)
	    continue
	}
	; Else := If(!inQuote) { ; quote is just over or not started
	currArg := Trim(SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart))

	If (realScriptPath) { ; script name found in cmdline, script args following
	    ; on first entrance, %1% must be = Trim(currArg; """")
	    If (currArg="/KillOnExit") {
		skipChars := currFragmentEnd ; next char after this argument
	    	global forceExit :=0
		OnExit("KillExeOnAhkExit")
	    } Else {
		If (parseArgsNum) {
		    parseArgNo++
		    If(parseArgNo > parseArgsNum) {
			parsedArgs.Push(SubStr(CommandLine, skipChars)) ; add rest of stings as parsedArgs[parseArgsNum+1]
			return parsedArgs
		    } Else {
			parsedArgs.Push(currArg)
			skipChars := currFragmentEnd
		    }
		} Else
		    parsedArgs := SubStr(CommandLine, skipChars) ; return rest of string, because no more args to be parsed
	    }
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
    
    return parsedArgs
}

KillExeOnAhkExit() {
    If (exePID)
	Process Close, %exePID%
    Loop {
	Process Close, %exename%
    } Until !ErrorLevel
}
