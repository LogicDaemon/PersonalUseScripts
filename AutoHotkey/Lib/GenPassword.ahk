﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

If (A_LineFile == A_ScriptFullPath) {
    local
    length := A_Args[1]
    If (!length)
        length := 14
    
    If (A_Args[2]) {
        AllowedChars := ExpandCharRanges(A_Args[2])
    } Else {
        AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        ;AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_ @#$*[]{};'\:,./?~``"
    }
    FileAppend % GenPassword(length, AllowedChars) "`n", *, CP1
    ExitApp
}

GenPassword(length := 20, ByRef AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") {
    local
    out := ""
    Loop %length%
    {
        Random charNo, 1, % StrLen(AllowedChars)+1
        out .= SubStr(AllowedChars,charNo,1), *, CP1
    }
    return out
}

ExpandCharRanges(ByRef charRanges) {
    local
    rangeCharCode := 0
    Loop Parse, charRanges
    {
        If (rangeCharCode) {
            rangeEndCode := Asc(A_LoopField)
            inc := rangeCharCode > rangeEndCode ? -1 : 1
            While (rangeCharCode != rangeEndCode)
                charList .= Chr(rangeCharCode += inc)
            rangeCharCode := 0
        } Else If (A_LoopField == "-" && lastChar != "") {
            rangeCharCode := Asc(lastChar)
        } Else {
            charList .= (lastChar := A_LoopField)
        }
    }
    If (rangeCharCode) ; - was last character in the string, not a range indicator
        charList .= "-"
    return charList
}
