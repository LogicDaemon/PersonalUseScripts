;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

StripNonfilenameChars(ByRef c) {
    n := ""
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,,<>:"/\|?*
	If (Asc(A_LoopField) > 31)
	    n .= A_LoopField
    return n
}
