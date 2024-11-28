;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

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

EnvGet LocalAppData, LOCALAPPDATA
FileReadLine emailSuffix, %LocalAppData%\_sec\EmailSuffix.txt, 1

Gui Add, Text, Section, Random email address
Gui Add, Text, Section xm, Service name
Gui Add, Edit, ys w200 vserviceName gGuiUpdateEmailAddress
Gui Add, Text, Section xm, e-mail suffix
Gui Add, Edit, ys w200 vemailSuffix gGuiUpdateEmailAddress, %emailSuffix%
Gui Add, Edit, xs w500 vemailAddress ReadOnly
Gui Add, Button, xs gGuiUpdateEmailAddress, Generate email

Gui Add, Text, Section xm, Pass Phrases
Gui Add, Edit, xs h250 w500 vPassPhrases Multi ReadOnly
Gui Add, Button, xs gGeneratePassPhrases, Generate Pass Phrases

Gui Show,, Pass Phrase Generator

If (clip := Clipboard) {
    GuiControl,, serviceName, % clip
    ; GenerateEmailAddress(clip)
}

GeneratePassPhrases()
Exit

GuiEscape:
GuiClose:
ExitApp

GeneratePassPhrases() {
    Local
    howmany := 20 ; document.results.howmany.value
    howlong := 6 ; document.results.howlong.value
    out := ""
    Loop % howmany
    {
        k := ""
        Loop % howlong
            k .= GetRandomWord() " "
        out .= SubStr(k, 1, -1) "`n"
    }
    GuiControl,, PassPhrases, % out
}

GuiUpdateEmailAddress(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    GuiControlGet serviceName,, serviceName
    GenerateEmailAddress(serviceName)
}

GenerateEmailAddress(serviceName) {
    Local

    prefix := ""
    Loop 3
        prefix .= GetRandomWord() "-"
    
    GuiControlGet emailSuffix,, emailSuffix
    email := prefix Normalize(serviceName) emailSuffix
    GuiControl,, emailAddress, % email
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
