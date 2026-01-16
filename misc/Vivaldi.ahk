;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force

EnvGet LocalAppData, LocalAppData

SetTitleMatchMode RegEx
VivaldiWinTitleRegex := ".+ - Vivaldi$ ahk_exe vivaldi\.exe"

If (A_Args.Length()) {
    cmdlArgs := ParseScriptCommandLine()
} Else If (WinExist(VivaldiWinTitleRegex)) {
    If (WinActive())
        ForceWinActivateBottom(VivaldiWinTitleRegex)
    Else
        ForceWinActivate(VivaldiWinTitleRegex)
    BackupSettingsToDropbox()
    ExitApp
}

pythonExe := FindPython("pythonw.exe")
If (!pythonExe)
    pythonExe := FindPython()
RunWait "%pythonExe%" "%A_ScriptDir%\py\Vivaldi_prefs_sync.py"
BackupSettingsToDropbox()

; HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet\Vivaldi.TMQETQK6ARTJHNK4EKWDEFN3NM\shell\open\command
For i, classMask in [ "VivaldiHTM"
                    , "Applications\vivaldi.exe"
                    , ["^VivaldiHTM\..*"]
                    , ["Vivaldi\..*"]] {
    If (aShellOpen := FindShellOpenByClass(classMask)) {
        cmdlArgs := InStr(aShellOpen[2], "%1") ? StrReplace( StrReplace( aShellOpen[2], """%1""", cmdlArgs ), "%1", cmdlArgs ) : aShellOpen[2] A_Space cmdlArgs ; replace "%1" or %1 in args
        For check, addArg in 	{ "--profile-directory=":         "--profile-directory=""Default"""
                                , "--process-per-site":           "--process-per-site" }
                                ;, "--disable-direct-composition": "--disable-direct-composition" }
            If (!InStr(cmdlArgs, check))
                cmdlArgs := addArg A_Space cmdlArgs
        nprivRun(aShellOpen[1], cmdlArgs)
        WinWait %VivaldiWinTitleRegex%,,30
        If (ErrorLevel) {
            ToolTip Failed to open %classMask%`, trying other options
            resetToolTip := True
        } Else {
            ForceWinActivate(VivaldiWinTitleRegex)
            break
        }
    }
}

If (resetToolTip)
    ToolTip
Else If (!aShellOpen)
    Throw Exception("Vivaldi path not found.")

ExitApp

FindShellOpenByClass(ByRef classRegexArrayOrName) {
    local
    For i, classRoot in [ "HKEY_CURRENT_USER\SOFTWARE\Classes"
                        , "HKEY_CLASSES_ROOT"
                        , "HKEY_CURRENT_USER\SOFTWARE\Clients\StartMenuInternet" ] {
        If (IsObject(classRegexArrayOrName)) {
            If (lastbs := InStr(classRegexArrayOrName[1], "\\", false, 0))
                classRoot .= "\" SubStr(classRegexArrayOrName[1], 1, lastbs-1)
            For className in RegQuery(classRoot, SubStr(classRegexArrayOrName[1], lastbs+2))
                If (IsObject(v := RegClassShellCmdApp(classRoot "\" className)))
                    return v
        } Else {
            If (IsObject(v := RegClassShellCmdApp(classRoot "\" classRegexArrayOrName)))
                return v
        }
    }
}

RegClassShellCmdApp(regPath, regKey := "") {
    local
    RegRead cmd, %regPath%\shell\open\command, %regKey%
    ;MsgBox % regPath "`n" regKey "`n" cmd
    If (cmd) {
        qapp := ParseCmdShellOpen(cmd)
        args := Trim(SubStr(cmd, StrLen(qapp)+1))
        If (FileExist(app := Trim(qapp, """")))
            return [app, args]
    }
}

RegQuery(regBasePath, regex, mode := "K") {
    local
    out := {}
    
    Loop Reg, %regBasePath%, %mode%
        If (A_LoopRegName ~= regex)
            out[A_LoopRegName] := A_LoopRegType
    return out
}

ParseCmdShellOpen(ByRef cmdShellOpen) {
    Local
    flagInsideQuote := 0
    Loop Parse, cmdShellOpen, %A_Space%
    {
        pathExec .= A_LoopField
        ; there may be several quotes w/o spaces in single argument -- IfInString A_LoopField, ", flagInsideQuote := !flagInsideQuote
        Loop Parse, A_LoopField, "
            flagInsideQuote := !flagInsideQuote
        If (flagInsideQuote) { ; since Loop ran (<number of «"»> + 1) times, currently flag in inverted, the substring is not in the quote, and the path is parsed completely
            break
        } Else {
            flagInsideQuote := !flagInsideQuote ; invert flag to restore meaning, because above Loop ran (<number of «"»> + 1) times (it counted quotes + 1)
            ; path is not yet parsed completely, keep appending it (with space delimeter)
            pathExec .= A_Space
        }
    }
    
    return pathExec
}

BackupSettingsToDropbox() {
    Local
    Global LocalAppData,resetToolTip
    RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname

    FilesToBackup := { "Bookmarks": ""
                     , "Calendar": ""
                     , "Contacts": ""
                     , "contextmenu.json": ""
                     , "Custom Dictionary.txt": ""
                     , "Notes": ""
                     , "Preferences": ""
                     , "Secure Preferences": ""
                     , "Shortcuts": ""
                     , "Web Data": "" }

    SkipProfiles := { "System Profile": ""
                    , "Guest Profile": "" }
    Try destDir := GetDropboxDir(false) "\Config\@" hostname "\Vivaldi\User Data\"
    If (!destDir) {
        ToolTip Dropbox folder not found. Backup skipped.
        resetToolTip := True
        return
    }
    SetWorkingDir % LocalAppData "\Vivaldi\User Data"

    Loop Files, *.*, D
    {
        If (SkipProfiles.HasKey(A_LoopFileName) || !FileExist(A_LoopFileFullPath "\Preferences"))
            Continue
        FileCreateDir %destDir%%A_LoopFileName%
        For fname in FilesToBackup {
            If (!FileExist(relPath := A_LoopFileFullPath "\" fname))
                Continue
            dest=%destDir%%relPath%
            While (CreateHardLink(relPath, dest)) {
                If (A_Index == 1) {
                    FileDelete %dest%
                    Continue
                }
                FileCopy %relPath%, %dest%, 1
                Break
            }
        }
    }
}

#include <ForceWinActivate>
#include <ForceWinActivateBottom>
#Include <nprivRun>
#include <GetDropboxDir>
#include <CreateHardLink>
