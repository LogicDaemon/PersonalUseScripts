;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

CutTrelloCardURL(ByRef url, mode := 0) {
    local ; Force-local mode
    static Modes := { 0: [1, 4]
                    , 1: [3]
                    , 2: [2] }
    out := ""
    If (!Modes.HasKey(mode))
        mode := 0
    ;                     1  2   3                 4
    If (RegexMatch(url, "S)^(.*(/c/([^/]+)/\d+))[^#]*(#.+)?", shn)) {
        For i, cutPart in Modes[mode]
            out .= shn%cutPart%
        return out
    }
}
