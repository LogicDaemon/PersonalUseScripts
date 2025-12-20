;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
#SingleInstance force

#Include <nprivRun>

SetTitleMatchMode RegEx
ChromeWinTitleRegex := ".+ - Google Chrome$ ahk_exe chrome\.exe"

If (A_Args.Length()) {
	CmdlArgs := ParseCommandLine()
} Else {
	If (WinExist(ChromeWinTitleRegex)) {
		; GetKeyState ShiftState, Shift, P
		; If (ShiftState=="U") {
		ForceWinActivate(ChromeWinTitleRegex)
		ExitApp
		; }
	}
}

For i, className in ["Applications\chrome.exe", "ChromeHTML", "ChromeBHTML", ""]
    Try If (FileExist(Trim(AppPath := ReadAppPathFromHKCRcmdShellOpen(className, cmdShellOpen), """")))
        Break

; ""C:\Program Files\Google\Chrome\Application\chrome.exe" --single-argument %1"

If (!AppPath)
    Throw Exception("Chrome path not found.")

replaceArgs := { "--single-argument": ""
               , "%1": ""
               , "%l": ""}

For arg, replacement in replaceArgs {
    offset := InStr(cmdShellOpen, arg)
    If (!offset)
        Continue
    argLen := StrLen(arg)
    Loop 2
    {
        prefixChar := SubStr(cmdShellOpen, offset-1, 1)
        suffixChar := SubStr(cmdShellOpen, offset + argLen, 1)
        If (A_Index == 1 && prefixChar == """" && suffixChar == """") ; The argument is quoted
            offset -= 1, argLen += 2
    }
    If (prefixChar == " ") { ; not in quotes
        ; cmdShellOpen := StrReplace(" " cmdShellOpen, arg, replacement ? " " replacement : "")
        cmdShellOpen := SubStr(cmdShellOpen, 1, offset-1) . replacement . SubStr(cmdShellOpen, offset + argLen)
    } Else {
        MsgBox 0x10, %A_ScriptName%, Unseparated argument "%arg%" found in HKCR\%className%`n`n%cmdShellOpen%, 30
    }
}

; Extract arguments from the cmdShellOpen by removing the path to the executable
CmdlArgs := StrReplace(SubStr(cmdShellOpen, StrLen(AppPath)+1) " " CmdlArgs, """%1""")

For check, addArg in { "--profile-directory=": "--profile-directory=""Default""" }
    ;, "--process-per-site":   "--process-per-site" }
    If (!InStr(CmdlArgs, check))
        CmdlArgs := addArg . " " . CmdlArgs
nprivRun(AppPath, CmdlArgs)
WinWait %ChromeWinTitleRegex%,,3
If (!ErrorLevel)
    ForceWinActivate(ChromeWinTitleRegex)

Process Exist, ollama.exe
If (!ErrorLevel) {
    Run "%A_AhkPath%" "%A_ScriptDir%\ollama_serve.ahk"
}

ExitApp

ReadAppPathFromHKCRcmdShellOpen(ByRef className, ByRef cmdShellOpen := "") {
    RegRead cmdShellOpen, HKEY_CLASSES_ROOT\%className%\shell\open\command
    If (!cmdShellOpen)
        Throw Exception("There's no shell\open\command for the class",, cmdShellOpen)
    flagInsideQuote:=0
    Loop Parse, cmdShellOpen, %A_Space%
    {
        pathExec .= A_LoopField
        ; there may be several quotes w/o spaces in single argument -- IfInString A_LoopField, "
        ;    flagInsideQuote:=!flagInsideQuote
        Loop Parse, A_LoopField, "
            flagInsideQuote:=!flagInsideQuote
        If (flagInsideQuote) { ; since Loop ran (<number of «"»> + 1) times, currently flag in inverted
            break
        } Else {
            flagInsideQuote:=!flagInsideQuote ; invert flag to restore meaning, because above Loop ran (<number of «"»> + 1) times (it counted quotes + 1)
            pathExec .= A_Space
        }
    }

    return pathExec
}

ForceWinActivate(ByRef title) {
    WinSet AlwaysOnTop, On, %ChromeWinTitleRegex%
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
