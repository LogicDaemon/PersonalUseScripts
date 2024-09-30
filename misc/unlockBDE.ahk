If (A_LineFile == A_ScriptFullPath)
    UnlockBDE("d:")

GetBDEKey(mountPoint) {
    local
    static key
    EnvGet LocalAppData, LOCALAPPDATA
    If (IsSet(key))
        return key
    keyFile := LocalAppData "\_sec\" RegExReplace(mountPoint, "[:\\]", "") ".key"
    f := FileOpen(keyFile, "r", "cp1")
    If (!f)
        Throw Exception("Failed to open key file", , keyFile)
    contents := f.Read()
    f.Close()
    If (!contents)
        Throw Exception("Failed to read key file", , keyFile)
    offset := 1
    cpn := CharsPerNumber(999999)
    key := ""
    Loop
    {
        encFrag := SubStr(contents, offset, cpn)
        offset += cpn
        key .= SubStr("000000" . CharsToNum(encFrag), -5) "-"
    } Until (offset >= StrLen(contents))
    key := SubStr(key, 1, -1)
    return key
}

UnlockBDE(mountPoint) {
    local
    key := GetBDEKey(mountPoint)
    cl = manage-bde -unlock %mountPoint% -RecoveryPassword "%key%"
    RunWait %cl%,, Min
    If (ErrorLevel)
        RunWait %comspec% /C "%cl% & manage-bde -unlock %mountPoint% -Password"
    return ErrorLevel
}

#include <NumToChars>
