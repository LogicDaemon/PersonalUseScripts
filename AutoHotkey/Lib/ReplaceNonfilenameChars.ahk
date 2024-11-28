;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ReplaceNonfilenameChars(ByRef c, ByRef filler := "") {
    n := ""
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,<>:"/\|?*
    {
        thisField := ""
        Loop Parse, A_LoopField
            thisField .= Asc(A_LoopField) > 31 ? A_LoopField : ""
        n .= (A_Index > 1 ? filler : "") thisField
    }
    return n
}
