FirstExisting(paths*) {
    Local
    For i,path in paths {
        If (FileExist(path))
            Return path
    }
    Return ""
}
