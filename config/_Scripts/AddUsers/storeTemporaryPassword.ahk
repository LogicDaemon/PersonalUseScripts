;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>#NoEnv
FileEncoding UTF-8

stdin := FileOpen("*", "r")
pw := stdin.ReadLine()
stdin.Close()

accname := A_Args[1]

If (HTTPReq("POST", "https://file.io/", "text=" pw, httpResponse := {}) < 300) {
    ;{"success":true,"key":"6lL5lq","link":"https://file.io/6lL5lq","expiry":"14 days"}
    ;https://temporary.pw/?key=6lL5lq
    resp := JSON.Load(httpResponse.text)
    FileAppend % resp.key "`n" httpResponse "`n", *

    If (!accname)
        ExitApp 0
    For i, line in GetPseudoSecrets() {
        data := StrSplit(line, A_Tab)
        ; data[1] = username
        ;      2  = url
        ;      3  = id-field
        ;      4  = temporary-pw-link-field
        ;global debug := {}
        If (data[1] == accname) {
            PostGoogleFormWithPostID(data[2], {(data[3]): {}, data[4]: "https://temporary.pw/?key=" resp.key})
            ;FileAppend % ObjectToText(debug) "`n", *
            ExitApp 0
        }
    }
    ExitApp 1
} Else {
    ExitApp 2
}

#include %A_LineFile%\..\..\Lib\HTTPReq.ahk
#include %A_LineFile%\..\..\Lib\JSON.ahk
#include %A_LineFile%\..\..\Lib\GetPseudoSecrets.ahk
#include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
