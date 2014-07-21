ReadSlowly(ByRef fname := "*", tries := 3, delay := 100) {
    fobj := FileOpen(fname, "r")
    If (!IsObject(fobj)) {
        Throw Exception("Error opening " fname,, A_LastError)
    } Else {
        Loop
        {
            readStrFragment := fobj.Read()
            If (readStrFragment) {
                readStr .= readStrFragment
            } Else {
                If (tries) {
                    Sleep %delay%
                    tries--
                } Else {
                    break
                }
            }
        }
        return readStr
    }
}
