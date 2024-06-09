;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

If (A_Args.Length() < 3) {
    MsgBox Syntax:`n%A_ScriptName% file.ini [section] key1=value1 key2=value2 ...
    ExitApp 1
}

iniFile := A_Args[1]

If (!FileExist(iniFile)) {
    FileAppend, , %iniFile%
    If (ErrorLevel) {
        MsgBox Error creating file %iniFile%
        ExitApp 1
    }
}

kv_index := 2
While kv := A_Args[kv_index++] {
    If (SubStr(kv, 1, 1) = "[" && SubStr(kv, 0) == "]") {
        section := SubStr(kv, 2, -1)
        Continue
    }
    kv_arr := StrSplit(kv, "=",, 2)
    k := kv_arr[1]
    v := kv_arr[2]

    IniWriteUnicode(iniFile, section, k, v)
}
ExitApp

#include <IniFilesUnicode>
