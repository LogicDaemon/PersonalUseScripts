FirstExisting(paths*) {
    local
    For i,path in paths {
        If (FileExist(path))
            return path
    }
    return ""
}
