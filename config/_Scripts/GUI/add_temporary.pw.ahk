;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

pw := Clipboard
If (!pw)
    hide=HIDE
InputBox pw,,,%hide%,,,,,,,%pw%
If (ErrorLevel)
    ExitApp 2

If (HTTPReq("POST", "https://file.io/", "text=" pw, response := "") >= 300)
    ExitApp 1

;{"success":true,"key":"6lL5lq","link":"https://file.io/6lL5lq","expiry":"14 days"}
;https://temporary.pw/?key=6lL5lq
resp := JSON.Load(response)
FileAppend % resp.key "`n" response "`n", *
url := "https://temporary.pw/?key=" resp.key
Clipboard := url
MsgBox URL %url% copied.
ExitApp 0

#include %A_LineFile%\..\..\Lib\HTTPReq.ahk
#include %A_LineFile%\..\..\Lib\JSON.ahk
#include %A_LineFile%\..\..\Lib\GetPseudoSecrets.ahk
#include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
