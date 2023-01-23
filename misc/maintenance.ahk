;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#SingleInstance ignore
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

global hiddenPIDs := {}

cmds := [ [A_AppData "\GHISLER\download pci.ids and convert to pci.db.ahk"]
        , [LocalAppData "\Programs\Total Commander\PlugIns\wdx\TrID_Identifier\TrID\update.cmd"]
        , [LocalAppData "\Scripts\WarframeCleanup.cmd"]
        , [A_ScriptDir "\compact Chrome cache.cmd", "/purgeCaches /purgeIndexedDB /chrome /chromium"]
        , [A_ScriptDir "\compact_lzx_ProgramsDirs.cmd"]
        , [SystemRoot "\System32\sc.exe", "config ""Backupper Service"" start= demand"]
        , [SystemRoot "\System32\sc.exe", "config ""SBIS3Plugin"" start= demand"] ]

Try {
    dirDropbox := GetDropboxDir()
    
    cmds.Push([dirDropbox "\Config\scripts\call _link.cmd for HOSTNAME and GROUP.cmd"]
            , [dirDropbox "\Config\scripts\copy tasks.cmd"]
            , [dirDropbox "\Config\scripts\export registry settings.cmd"]
            , [A_ScriptDir "\Vivaldi_prefs_backup.ahk"] )
} Catch {}

killProcesses = [ "update_notifier.exe"
                , "DropboxUpdate.exe" ]

yesterday := ""
yesterday += -1, Day
Loop Files, %A_Temp%\*.*, D
{
    If (FileExist(A_LoopFileFullPath "\DismHost.exe")
        && A_LoopFileTimeModified < yesterday) {
        FileRemoveDir %A_LoopFileFullPath%, 1
    }
}

For i, procName in killProcesses {
    WinKill ahk_exe %procName%,,5
    While true {
        Process Exist, %procName%
        If (!ErrorLevel)
            break
        If (prevPID == ErrorLevel) {
            RunWait taskkill.exe /IM %procName% /F
            break
        } Else {
            prevPID := ErrorLevel
            Process Close, %procName%
        }
    }
}

DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00100000) ; PROCESS_MODE_BACKGROUND_BEGIN=0x00100000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
For i, cmd in cmds
    RunScript(cmd)

Loop
{
    c := 0
    For rpid, title in hiddenPIDs {
        Process WaitClose, %rpid%, 3
        If (!ErrorLevel)
            hiddenPIDs.Delete(rpid)
        Else
            c++
    }
    Menu Tray, Tip, %c% processes still running
} Until !c
Menu Tray, Tip, All maintenance processes finished
DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00200000) ; PROCESS_MODE_BACKGROUND_END=0x00200000 https://msdn.microsoft.com/en-us/library/ms686219.aspx

Process Priority,, Low

extToCompact={"exe": "", "dll": "", "sys": "", "mui": "", "eml": "", "qml": "", "js": "", "pyd": "", "py": "", "qmltypes": "", "rcc": "", "inf": "", "manifest": ""}
dirs := {}
For envvar in {"UserProfile": "", "ProgramFiles": "", "ProgramFiles(x86)": "", "ProgramW6432": ""} {
    EnvGet path, %envvar%
    If (InStr(FileExist(path), "D"))
        dirs[path] := ""
}
If (InStr(FileExist("w:\Temp"), "D"))
    dirs["w:\Temp"] := ""
For dir in dirs {
    Menu Tray, Tip, Listing all subdirs in %dir%
    Loop Files, %dir%\*.*, RF
    {
        If (A_LoopFileDir != lastFileDir) {
            lastFileDir := A_LoopFileDir
            Menu Tray, Tip, Compacting %lastFileDir%
            Sleep -1
        }
        If (A_LoopFileSize > 4095 && extToCompact.HasKey(A_LoopFileExt) && !InStr(A_LoopFileAttrib, "C")) {
            MsgBox % A_LoopFileFullPath "`n" A_LoopFileAttrib
            If (rPID)
                Process WaitClose, %rPID%, 30000
            If (ErrorLevel)
                ErrorCount++
            If (ErrorCount > 1000)
                ExitApp ErrorCount
            Run %SystemRoot%\System32\compact.exe /C /Q /EXE:LZX "%A_LoopFileFullPath%", %A_Temp%, Hide, rPID
        }
    }
}

ExitApp

RunScript(cmdline) {
    ; either command line string
    ; or [executable, arguments, dir, mode]
    global hiddenPIDs
    mode := "Hide"
    
    If (IsObject(cmdline)) {
        executable := cmdline[1]
        If (cmdline[3]) {
            dir := cmdline[3]
            SplitPath executable,,,ext
        } Else {
            SplitPath executable,,dir,ext
        }
        mode := cmdline[4] ? cmdline[4] : mode
        cmdline := """" Trim(cmdline[1], """") """ " cmdline[2]
    } Else {
        executable := Trim(ParseCommandLine(A_LoopField)[0], """")
        SplitPath executable,,dir,ext
    }

    If (ext="cmd" || ext="bat")
        cmdline=%comspec% /C "%cmdline%"
    Else If (ext=="ahk")
        cmdline="%A_AhkPath%" %cmdline%

    Run %cmdline%, %dir%, UseErrorLevel %mode%, rpid
    hiddenPIDs[rpid] := cmdline
}

#include <GetDropboxDir>
