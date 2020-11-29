;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
dirDropbox := GetDropboxDir()
EnvSet dirDropbox, %dirDropbox%

global hiddenPIDs := {}

commands =
(
%SystemRoot%\System32\sc.exe config "Backupper Service" start= demand
"%LocalAppData%\Programs\Total Commander\PlugIns\wdx\TrID_Identifier\TrID\update.cmd"
"%A_AppData%\GHISLER\download pci.ids and convert to pci.db.ahk"
"%dirDropbox%\Config\scripts\call _link.cmd for HOSTNAME and GROUP.cmd"
"%dirDropbox%\Config\scripts\copy tasks.cmd"
"%dirDropbox%\Config\scripts\export registry settings.cmd"
"%LocalAppData%\Scripts\WarframeCleanup.cmd"
"%A_ScriptDir%\compact Chrome cache.cmd" /purgeCaches /purgeIndexedDB /chrome
"%A_ScriptDir%\compact_lzx_ProgramsDirs.cmd"
)

DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00100000) ; PROCESS_MODE_BACKGROUND_BEGIN=0x00100000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
Loop Parse, commands, `n
    RunScript(A_LoopField)

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
    Loop Files, %dir%, RF
    {
        
        If (A_LoopFileSize > 4095 && extToCompact.HasKey(A_LoopFileExt)) {
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

DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00200000) ; PROCESS_MODE_BACKGROUND_END=0x00200000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
ExitApp

RunScript(ByRef cmdline) {
    global hiddenPIDs
    executable := Trim(ParseCommandLine(A_LoopField)[0], """")
    SplitPath executable,,dir,ext
    
    
    If (ext="cmd" || ext="bat")
        runcmdline=%comspec% /C "%cmdline%"
    Else If (ext=="ahk")
        runcmdline="%A_AhkPath%" %cmdline%
    Else
        runcmdline:=cmdline
    Run %runcmdline%, %dir%, UseErrorLevel Hide, rpid
    hiddenPIDs[rpid] := cmdline
}

#include <GetDropboxDir>
