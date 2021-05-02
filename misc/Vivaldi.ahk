;by LogicDaemon <www.logicdaemon.ru>1
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#NoTrayIcon
#SingleInstance force

SetTitleMatchMode RegEx
VivaldiWinTitleRegex := ".+ - Vivaldi$ ahk_exe vivaldi\.exe"

If (A_Args.Length()) {
    CmdlArgs := ParseScriptCommandLine()
} else {
    If (WinExist(VivaldiWinTitleRegex)) {
        If (WinActive())
            ForceWinActivateBottom(VivaldiWinTitleRegex)
        Else
            ForceWinActivate(VivaldiWinTitleRegex)
	ExitApp
    }
}

For i, classMask in ["VivaldiHTM", "Applications\vivaldi.exe", ["^VivaldiHTM\..*"]] {
    If (aShellOpen := FindShellOpenByClass(classMask)) {
        CmdlArgs .= A_Space StrReplace( aShellOpen[2], """%1""" ) ; remove "%1" from args
        For check, addArg in 	{ "--profile-directory=": "--profile-directory=""Default"""
                                , "--process-per-site":   "--process-per-site" }
            If (!InStr(CmdlArgs, check))
                CmdlArgs := addArg A_Space CmdlArgs
        nprivRun(aShellOpen[1], CmdlArgs)
        WinWait %VivaldiWinTitleRegex%,,3
        If (!ErrorLevel) {
            ForceWinActivate(VivaldiWinTitleRegex)
            break
        }
    }
}

If (!aShellOpen)
    Throw Exception("Vivaldi path not found.")

ExitApp

FindShellOpenByClass(ByRef classRegexArrayOrName) {
    For i, classRoot in ["HKEY_CURRENT_USER\SOFTWARE\Classes", "HKEY_CLASSES_ROOT"] {
        If (IsObject(classRegexArrayOrName)) {
            If (lastbs := InStr(classRegexArrayOrName[1], "\\", false, 0))
                classRoot .= "\" SubStr(classRegexArrayOrName[1], 1, lastbs-1), classRegexArrayOrName := SubStr(classRegexArrayOrName[1], lastbs+2)
            For className in RegQuery(classRoot, classRegexArrayOrName[1])
                If (IsObject(v := RegClassShellCmdApp(classRoot "\" className "\shell\open\command")))
                    return v
        } Else {
            If (IsObject(v := RegClassShellCmdApp(classRoot "\" classRegexArrayOrName "\shell\open\command")))
                return v
        }
    }
}

RegClassShellCmdApp(regPath, regKey := "") {
    RegRead cmd, %regPath%, %regKey%
    If (cmd) {
        qapp := ParseCmdShellOpen(cmd)
        args := Trim(SubStr(cmd, StrLen(qapp)+1))
        If (FileExist(app := Trim(qapp, """")))
            return [app, args]
    }
}

RegQuery(regBasePath, regex, mode := "K") {
    out := {}
    
    Loop Reg, %regBasePath%, %mode%
        If (A_LoopRegName ~= regex)
            out[A_LoopRegName] := A_LoopRegType
    return out
}

ParseCmdShellOpen(ByRef cmdShellOpen) {
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

#include <ForceWinActivate>
#include <ForceWinActivateBottom>
#Include <nprivRun>
