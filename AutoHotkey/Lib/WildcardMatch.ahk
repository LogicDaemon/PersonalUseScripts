;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

WildcardMatch(ByRef string, ByRef wildcard) {
    ;MsgBox % "string: " string "`nwildcard: " wildcard
    maskPos := InStr(wildcard, "*")
    If (maskPos) {
        If (SubStr(string, 1, maskPos-1) != SubStr(wildcard, 1, maskPos-1))
            return false
        nextMaskPos := InStr(wildcard, "*",, maskPos+1)
        If (nextMaskPos) {
            nextSubstr := SubStr(wildcard, maskPos+1, nextMaskPos-maskPos-1)
            nextSubstrPos := maskPos-1
            ;MsgBox % "nextSubstrPos: " nextSubstrPos "`nnextSubstr: " nextSubstr
            While nextSubstrPos := InStr(string, nextSubstr,, nextSubstrPos+1)
                If (WildcardMatch(SubStr(string, nextSubstrPos), SubStr(wildcard, nextMaskPos)))
                    return true
            return false
        } Else {
            tail := SubStr(wildcard, maskPos+1)
            return !tail || tail = SubStr(string, -StrLen(tail)+1)
        }
    } Else {
        return string = wildcard
    }
}
