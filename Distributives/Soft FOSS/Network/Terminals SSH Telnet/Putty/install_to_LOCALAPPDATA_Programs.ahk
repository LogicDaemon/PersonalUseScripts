;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#Warn
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

#include <find7zexe>

tmpDir = %LocalAppData%\Programs\putty.tmp-update
FileRemoveDir %tmpDir%, 1
RunWait %exe7z% x -aoa -o"%tmpDir%" -- "%A_ScriptDir%\putty.zip",, Min
FileGetVersion ver, %tmpDir%\PUTTY.EXE
ver := CutFirstMatchingSuffix(ver, ".0.0", ".0")
newVerDir = %LocalAppData%\Programs\putty-%ver%
If (FileExist(newVerDir)) {
    FileAppend "%newVerDir%" exists`n, *, CP1
    FileRemoveDir %tmpDir%, 1
} Else {
    FileMoveDir %tmpDir%, %newVerDir%, R
    If (ErrorLevel) {
        FileRemoveDir %tmpDir%, 1
        ExitApp ErrorLevel
    }
}

destDir = %LocalAppData%\Programs\putty
UpdateJunction(newVerDir, destDir)
ExitApp ErrorLevel

UpdateJunction(newVerDir, destDir) {
    local
    If (FileExist(destDir ".new")) {
        FileAppend "%destDir%.new" exists`, removing`n, *, CP1
        FileRemoveDir %destDir%.new
        If (ErrorLevel) {
            FileAppend "%destDir%.new" removal failed`n, *, CP1
            ExitApp %ErrorLevel%
        }
    }
    RunWait %comspec% /C "MKLINK /J "%destDir%.new" "%newVerDir%"",,Min UseErrorLevel
    If (ErrorLevel) {
        FileAppend Failed creating reparse point`n, *, CP1
        ExitApp %ErrorLevel%
    }
    FileRemoveDir %destDir%
    If (FileExist(destDir)) {
        FileAppend Failed removing %destDir%`n, *, CP1
        ExitApp ErrorLevel ? ErrorLevel : 128
    }
    FileMoveDir %destDir%.new, %destDir%, R
}

CutFirstMatchingSuffix(ByRef str, suffixes*) {
    For i, suffix in suffixes {
        suflen := StrLen(suffix)
        ; MsgBox % suflen "`n" SubStr(str, -suflen+1) "`n" suffix "`n" (SubStr(str, -suflen+1) == suffix)
        If (SubStr(str, -suflen+1) == suffix)
            return SubStr(str, 1, suflen)
        return str
    }
}
