;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

RegexProcess(ByRef src, ByRef regex, procFunc) {
    out := "", matchCount := 0, prevOffset := 1, nextOffset := 0
    Loop
    {
        If (nextOffset := RegexMatch(src, regex, match, nextOffset+1)) {
            out .= SubStr(src, prevOffset, nextOffset-prevOffset) ; append non-matching part
            ;MsgBox src: %src%`nregex: %regex%`nmatch: %match%`nout: %out%
            matchCount++, nextOffset := prevOffset := nextOffset + StrLen(match), out .= procFunc.Call(match, regex)
        } Else {
            ErrorLevel := !matchCount
            return out . SubStr(src, prevOffset)
        }
    }
}
