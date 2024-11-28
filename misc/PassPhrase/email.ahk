;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance Ignore
FileEncoding UTF-8

EnvGet LocalAppData, LOCALAPPDATA
FileReadLine emailSuffix, %LocalAppData%\_sec\EmailSuffix.txt, 1

; RtlGenRandom ( SystemFunction036 ) https://docs.microsoft.com/en-us/windows/win32/api/ntsecapi/nf-ntsecapi-rtlgenrandom
RtlGenRandom := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "Advapi32.dll", "Ptr"), "AStr", "SystemFunction036", "Ptr")
; on Vista and later, maybe DllCall("Bcrypt.dll\BCryptGenRandom", "Ptr",0, "UIntP",Num:=0, "Int",4, "Int",0x2) is better

Global minw := 1, maxw := 0, twords := 0, cwords := [], nwords := []
Loop Read, %A_ScriptDir%\wordstab.txt
{
    cwords.Push(A_LoopReadLine)
    maxw := A_Index
    thisLineWords := StrLen(A_LoopReadLine) // A_Index
    nwords[A_Index] := thisLineWords
    twords += thisLineWords
}
thisLineWords := ""
; twords := 27489
; , nwords := [3, 76, 741, 2478, 4075, 5946, 7016, 7154]

SendMode Input
ToolTip % v
SendRaw % GenerateEmailAddress(Clipboard)
ToolTip
ExitApp

GenerateEmailAddress(serviceName) {
    Local
    Global emailSuffix

    prefix := ""
    Loop 3
        prefix .= GetRandomWord() "-"
    
    Return prefix Normalize(serviceName) emailSuffix
}

Normalize(str) {
    Local
    Static notAllowedRE := "[^A-Za-z0-9\-\.]+"
    If (str ~= "^\w+://") {
        dom := GetDomain(str)
        str := dom ? dom : str
    }
    ; RegExReplace(Haystack, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPos = 1])
    Return SubStr(RegExReplace(str, notAllowedRE, "_"), 1, 32)
}

GetDomain(url) {
    Local
    ; FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos)
    pos := RegExMatch(url, "://([^/]+)", out)
    Return pos ? out1 : ""
}

GetRandomWord() {
    Local
    Global twords
    Return IndexWord(Mod(RandomInt(), twords))
}

IndexWord(index) {
    Local
    Global minw, maxw, nwords, cwords
    j := minw
    While (index >= nwords[j] && j <= maxw) {
        index -= nwords[j]
        j++
    }
    Return SubStr(cwords[j], j * index + 1, j)
}

; Generate a secure random 4-byte integer
RandomInt() {
    Global RtlGenRandom
    ret := DllCall(RtlGenRandom, "UIntP", rand:=0, "Int", 4)
    If (ErrorLevel || !ret)
        Throw Exception("RtlGenRandom failed: " ErrorLevel,, A_LastError)
    Return rand
}

#include <Crypt>
