; by User
;     Posts: 407
;     Joined: 26 Jun 2017
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=59466&sid=5e3e169c9c91641bf5d9ad5a7725a2dd
RegExEsc(String, Options := "")		;_________ RegExEsc(Function) - v1.0 __________
{

if (Options == "$")
return, RegExReplace(String, "\$", "$$$$")	;to be used with "RegExReplace" third parameter! ("$$" represents one literal "$")

return, "\E\Q" RegExReplace(String, "\\E", "\E\\E\Q") "\E"	;to be used with "RegExMatch" and "RegExReplace" second parameters! ("\\" represents one literal "\")

}
