LatestExisting(mask, mode := "F") {
    local
    latestMTime := 0, latestFile := ""
    Loop Files, %mask%, %mode%
    {
        If (A_LoopFileTimeModified > latestMTime)
        {
            latestMTime := A_LoopFileTimeModified
            latestFile := A_LoopFileFullPath
        }
    }
    return latestFile
}
