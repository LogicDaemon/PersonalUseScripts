;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Files, %A_ScriptDir%\..\bin, D
{
    If (binPath)
        Throw Exception("There is more than 1 bin")
    notepad2Path := A_LoopFileLongPath "\Notepad2.exe"
}
If (!FileExist(notepad2Path))
    Throw Exception("Notepad2 executalbe is missing",, notepad2Path)

If (SubStr(notepad2Path, 1, 2) == "\\") {
    MsgBox 0x131, %A_ScriptName%, The notepad2 path is on the network:`n`n%notepad2Path%`n`nProceeding will configure the associations with it.
    IfMsgBox Cancel
        ExitApp
}

shellCommand = "%notepad2Path%" "`%l"

If (InStr(notepad2Path, LocalAppData)) {
    notepad2ExpandPath := StrReplace(notepad2Path, LocalAppData, "%LOCALAPPDATA%")
    shellCommandExpand = "%notepad2ExpandPath%" "`%l"

    RegWrite REG_EXPAND_SZ, HKEY_CLASSES_ROOT\Applications\Notepad2.exe\shell\open\command,, %shellCommandExpand%
    RegWrite REG_EXPAND_SZ, HKEY_CLASSES_ROOT\Applications\Notepad2.exe\shell\edit\command,, %shellCommandExpand%
    RegWrite REG_EXPAND_SZ, HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Edit\Command,, %shellCommandExpand%
} Else {
    RegWrite REG_SZ, HKEY_CLASSES_ROOT\Applications\Notepad2.exe\shell\open\command,, %shellCommand%
    RegWrite REG_SZ, HKEY_CLASSES_ROOT\Applications\Notepad2.exe\shell\edit\command,, %shellCommand%
    RegWrite REG_SZ, HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Edit\Command,, %shellCommand%
}
