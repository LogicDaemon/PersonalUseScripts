;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RunWait cmd /C "manage-bde -protectors -get D: -Type recoverypassword >%TEMP%\rp_d.tmp",, Min UseErrorLevel
If (ErrorLevel) {
    FileDelete %TEMP%\rp_d.tmp
    Throw Exception("Failed to get protectors for D:")
}

Loop Read, %TEMP%\rp_d.tmp
{
    trimmed := Trim(A_LoopReadLine)
    lastLine := trimmed ? trimmed : lastLine
}
FileDelete %TEMP%\rp_d.tmp
If (!lastLine)
    Throw Exception("Failed to read the recovery key")

SaveBDEKey("d:", lastLine)
ExitApp

SaveBDEKey(mountPoint, key) {
    Local
    Global LocalAppData
    keyFile := LocalAppData "\_sec\" RegExReplace(mountPoint, "[:\\]", "") ".key"
    FileGetSize size, %keyFile%
    If (size)
        Throw Exception("Key file already exists", , keyFile)
    f := FileOpen(keyFile, "w", "cp1")
    If (!f)
        Throw Exception("Failed to open key file", , keyFile)
    offset := 1
    Loop Parse, key, -
        f.Write(NumToChars(A_LoopField, 999999, 0))
}

#include <NumToChars>
