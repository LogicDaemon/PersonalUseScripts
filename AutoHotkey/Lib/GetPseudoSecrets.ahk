;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

GetPseudoSecrets(lineNo := "") {
    static secretsPath := A_LineFile "\..\..\pseudo-secrets\" A_ScriptName ".txt"
         , data := "", fullDataRead := 0
    If (!fullDataRead) { ; reading
        If (!data)
            data := []
        If (lineNo) {
            If (!data.HasKey(lineNo))
                FileReadLine line, %secretsPath%, %lineNo%
        } Else {
            Loop Read, %A_LineFile%\..\..\pseudo-secrets\%A_ScriptName%.txt
                data[A_Index] := A_LoopReadLine
            fullDataRead := 1
        }
    }
    If (lineNo) ; returning
        return data[lineNo]
    Else
        return data
}
