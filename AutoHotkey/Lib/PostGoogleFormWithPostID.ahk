;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

PostGoogleFormWithPostID(ByRef URLs, ByRef kv) {
    global debug
    ; (, ByRef postID:="", ByRef trelloURL:="") {

    ; URLs : 	"https://form_address"
    ;	or	["https://form_address", "https://verify_sheet_address"]
    ; kv: 	{ form_field_with_IDs: ExpandPostIDs_query [, form_field: value [, form_field2: value2 [, …]]] }
    ;
    ;   ExpandPostIDs_query is { [idFuncName: "prefix" [, idFuncName: "prefix" [, …]]] }
    ;	  idFuncNames are queries from %A_LineFile%\..\ExpandPostIDs.ahk or quoted func names,
    ;     prefix is any text.

    For i, v in kv
        If (IsObject(v))
            kv[i] := ExpandPostIDs(v)

    If (IsObject(URLs)) {
        URL := URLs[1]
        verifyURL := URLs[2]
    } Else
        URL := URLs
    If (!(SubStr(URL, 1, 8) == "https://" || SubStr(URL, 1, 7) == "http://"))
        Throw Exception("URL must start with http:// or https://",,URL)
    Loop
    {
        If (success:=PostGoogleForm(URL, kv, 2, A_Index * 1000)) { ;PostGoogleForm(URL, kv, tries, retryDelay)
            If (verifyURL) {
                ;ToDo: load verifyURL and check if there is the line with the last postID
            }
            break
        }
        If (IsObject(debug))
            debugtxt := ObjectToText(debug)
        MsgBox 53, %A_ScriptName%, Error posting.`n[Try %A_Index%`, autoretry in 5 minutes]`n`n%debugtxt%, 300
        IfMsgBox Cancel
            break
    }
    return success
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    FileEncoding UTF-8
    kv := {}, postIDfieldFound := 0
    For i, arg in A_Args {
        If (i>1) {
            If (!foundPos := InStr(arg, "="))
                Throw Exception("Argument """ arg """ must be in format ""key=value""", "([^=]+)=(.+)", arg)
            lastKey := SubStr(arg, 1, foundPos-1)
            kv[lastKey] := SubStr(arg, foundPos+1)
            If (!(postIDfieldFound || kv[lastKey]))
                kv[lastKey] := {}, postIDfieldFound := 1 ; first empty value will be used for postID
        } Else
            URL:=arg
    }
    ExitApp !PostGoogleFormWithPostID(URL,kv)
}

#include %A_LineFile%\..\PostGoogleForm.ahk
#include %A_LineFile%\..\CutTrelloCardURL.ahk
#include %A_LineFile%\..\ExpandPostIDs.ahk
#include %A_LineFile%\..\ObjectToText.ahk
