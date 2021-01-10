VersionStringToArray(verString) {
    local
    out := []
    Loop Parse, verString, .
        out.Push(A_LoopField)
    return out
}
