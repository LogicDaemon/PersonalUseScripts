;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force
SetTitleMatchMode RegEx

If (A_ScriptFullPath == A_LineFile || !nameDB || !dirDB || !commandLineParam) {
    foundKdb := 0
    If (!skipDropbox)
        CheckLaunchDropbox()

    preseltxt := "-preselect:"
    preseltxtlen := StrLen(preseltxt)
    For i, arg in A_Args {
	If (SubStr(arg, 1, preseltxtlen) = preseltxt) {
	    key := SubStr(arg, preseltxtlen+1)
        } Else If (!foundKdb) {
	    SplitPath arg, nameDB, dirDB, extDB
	    foundKdb := extDB="kdb"
	}
    }
    
    commandLineParam := ParseScriptCommandLine()
}

KeePassExePath := KeepassExeUpdated()
SplitPath KeePassExePath, KeePassExeName

If (WinExist("ahk_exe " KeePassExeName)) {
    WinGetTitle KeePassTitle
    If (KeePassTitle = (nameDB . " - KeePass Password Safe")) {
	WinActivate
	Exit
    }
    If (       KeePassTitle = " [Locked] - Keepass"
            || KeePassTitle = nameDB . " [Locked] - Keepass"
	    || KeePassTitle = "KeePass" ; no db open
	    || KeePassTitle = "Open Database - " . nameDB) { ; database opening window
        Loop 20
        {
            If (A_Index == 1) {
                GroupAdd keepass, ahk_exe %KeePassExeName%
                WinKill ahk_group keepass
                TrayTip 0,, Waiting for KeePass to exit…
            } Else {
                TrayTip 0,, Killing KeePass process…
                Process Close, %KeePassExeName%
                closed := ErrorLevel
            }
            Process Exist, %KeePassExeName%
            If (closed := !ErrorLevel)
                break
            RunWait "%KeePassExePath%" --exit-all
            ToolTip Cloudn't close KeePass, retrying
            Sleep % A_Index * 50
            TrayTip
        }
    } Else {
	WinActivate
	Exit
    }
}

Loop Files, %dirDB%\*.lock
{
    If (A_LoopFileName = nameDB . ".lock") {
	;lck := ReadKeePassLockFile(A_LoopFileFullPath)
	;MsgBox % "Locked by " lck.user " on " lck.host
    } Else {
	FileDelete %A_LoopFileFullPath%
    }
}

Loop 3
{
    While WinExist("ahk_exe " KeePassExeName) {
        ToolTip Another KeePass is active. Waiting for it to close.
        WinWaitClose
    }
    Loop
    {
        Process Exist, %KeePassExeName%
        If (!ErrorLevel)
            break
        ToolTip There is a %KeePassExeName% process but no window. Killing it.
        Process Close, %KeePassExeName%
    }
    ToolTip Starting %KeePassExePath%
    Run "%KeePassExePath%" %commandLineParam%,,,rPID
    WinWait ahk_pid %rPID%,,1
} Until !ErrorLevel
WinActivate
ToolTip

;dropbox desktop: *(*'s conflicted copy *).kdb
;dropsync android: * (conflict *).kdb
Loop Files, %dirDB%\*.kdb
    If(A_LoopFileName != nameDB && A_LoopFileName ~= "i).+\((.+'s conflicted copy|conflict) .+\).kdb$")
	resolveSuccess := ResolveConflict(A_LoopFileName)

Exit

CheckLaunchDropbox() {
    RegRead dropboxClientVer, HKEY_CURRENT_USER\SOFTWARE\Dropbox\Client, Version
    If ( dropboxClientVer
      && FileExist(A_ScriptDir "\Dropbox.ahk")
      && FileExist(A_AppData "\Dropbox\*.*") ) {
        Process Exist, Dropbox.exe
        If (!ErrorLevel)
            RunWait "%A_AhkPath%" "%A_ScriptDir%\Dropbox.ahk"
    }
}

KeepassExeUpdated() {
    Loop 2
    {
        Try {
            KeePassExePath := Find_KeePass_exe()
            
            RegRead lastUpdateCheck, HKEY_CURRENT_USER\SOFTWARE\LogicDaemon\KeePassLauncher, LastUpdateCheckYYYYMMDDHH
        }

        If (!lastUpdateCheck || DaysSince(lastUpdateCheck) >= 1) {
            mode := lastUpdateCheck ? "background " : ""
            TrayTip Starting %mode%autoupdate...
            If (lastUpdateCheck) {
                Run "%A_AhkPath%" "%A_ScriptDir%\update_KeePass.ahk"
            } Else {
                RunWait "%A_AhkPath%" "%A_ScriptDir%\update_KeePass.ahk"
                break
            }
        }
    }
    RegWrite REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\LogicDaemon\KeePassLauncher, LastUpdateCheckYYYYMMDDHH, % SubStr(A_Now, 1, 10) ;REG_DWORD max is 4294967295
    
    return KeePassExePath
}

ResolveConflict(conflictedDBPath) {
    global KeePassExeName,key
    MsgBox Conflict: %conflictedDBPath%
    TrayTip There is a conflicted kdb copy., Waiting 30 sec to paste "%conflictedDBPath%" to import window, 30, 33
    WinWait ^Open$ ahk_class ^#32770$ ahk_exe %KeePassExeName%,,30
    If (ErrorLevel) ;  timeout
	return 1
    AutomateOpenFile(A_LoopFileFullPath)
    
    SetTitleMatchMode 3
    WinWait Open Database - %conflictedDBPath% ahk_class #32770 ahk_exe %KeePassExeName%,,5
    SetTitleMatchMode RegEx
    ControlClick &Use master password and key file
    ControlClick Button3
    AutomateOpenFile(key)
    
    SetTitleMatchMode 3
    WinWaitActive Open Database - %conflictedDBPath% ahk_class #32770 ahk_exe %KeePassExeName%
    SetTitleMatchMode RegEx
    ControlClick Edit1
    
    return 0
}

AutomateOpenFile(filepath, OpenWindowTitleRegEx := "^Open$") {
    global KeePassExeName
    WinWaitActive %OpenWindowTitleRegEx% ahk_class #32770 ahk_exe %KeePassExeName%
    ControlFocus Edit1
    Sleep 50
    Control EditPaste, %filepath%, Edit1
    ControlClick Button1
}

ReadKeePassLockFile(path) {
    readLockFile := Object()
    file := FileOpen(path,"r")
    readLockFile.year := file.ReadUShort()
    readLockFile.month := file.ReadUChar()
    readLockFile.day := file.ReadUChar()
    readLockFile.hour := file.ReadUChar()
    readLockFile.min := file.ReadUChar()
    readLockFile.sec := file.ReadUChar()
    lockFileText := file.ReadLine()
    file.Close()
    Loop Parse, lockFileText, @, %A_Space%
    {
	If (A_Index==1) {
	    readLockFile.user := A_LoopField
	} Else If (A_Index==2) {
	    readLockFile.host := A_LoopField
	} Else {
	    Throw "Misunderstood lock file format, more than @ in user@host"
	}
    }
    return readLockFile
}

DaysSince(ByRef yyyymmdd) {
    daysSince=
    daysSince -= yyyymmdd, Days
    return daysSince
}

FirstExisting(paths*) {
    For i,path in paths {
        If (FileExist(path))
            return path
    }
    return ""
}

#include <find_KeePass_exe>
