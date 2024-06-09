FirstExistingFilePath(paths*) {
    local
    For i,path in paths {
        If (FileExist(path))
            Loop Files, %path%
                Return A_LoopFileFullPath
    }
    return ""
}
