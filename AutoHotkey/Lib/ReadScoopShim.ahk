ReadScoopShim(ByRef shim) {
    Local
    data := {}
    Loop Read, %shim%
    {
        lineData := StrSplit(A_LoopReadLine, "=",, 2)
        data[Trim(lineData[1])] := Trim(lineData[2])
    }
    Return data
}
