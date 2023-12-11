;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance force

EnvGet LocalAppData, LOCALAPPDATA
EnvGet SecretDataDir, SecretDataDir

SetTitleMatchMode RegEx
ChromiumWinTitleRegex := ".+ - Chromium$ ahk_exe chrome.exe"
If %0%
{
    cmdl_args := ParseCommandLine()
} else {
    If (WinExist(ChromiumWinTitleRegex)) {
;	GetKeyState ShiftState, Shift, P
;	If (ShiftState=="U") {
	ForceWinActivate()
	ExitApp
;	}
    }
}

set_cmds := ""
For i, varname in ["GOOGLE_DEFAULT_CLIENT_ID", "GOOGLE_DEFAULT_CLIENT_SECRET", "GOOGLE_API_KEY"] {
    IniRead value, %SecretDataDir%\Chromium Google API keys.ini,Chromium-local-build,%varname%,%A_Space%
    EnvSet %varname%, % value
    set_cmds .= "SET """ varname "=" value """ & "
}

app_path:=FirstExisting(LocalAppData "\Programs\Chromium\RunLatest.ahk", LocalAppData "\Programs\Chromium\current\chrome.exe")
If (!app_path)
    Throw Exception("Chromium executable not found")
nprivRun(comspec, "/C """ set_cmds . """" . app_path . """ --process-per-site " . cmdl_args . """")
;nprivRun does not pass environment, so alternate is Run "%AppPath%" --process-per-site %cmdl_args%

WinWait %ChromiumWinTitleRegex%,,3
If (!ErrorLevel && !WinActive())
    ForceWinActivate()

Sleep 10000
RunWait "%A_AhkPath%" "%A_ScriptDir%\update_chromium.ahk"
ExitApp

ForceWinActivate() {
    WinSet AlwaysOnTop, On
    Sleep 0
    WinSet AlwaysOnTop, Off
    WinActivate
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

#Include <nprivRun>
