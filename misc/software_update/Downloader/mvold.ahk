#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (A_ScriptFullPath == A_LineFile) {
    Loop % A_Args.Length()
        MoveToOld(A_Args[A_Index])
    ExitApp
}

GuessBaseDistributives(ByRef outDir) {
    ; Normalize outDir
    Loop Files, %outDir%, D
    {
        path := A_LoopFileLongPath
        break
    }
    ; 
    Loop
    {
        ; SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
        prevPath := path
        SplitPath path, dirName, path
        If (!dirName || StrLen(path) < 2 || prevPath == path)
            Break
        prefix := SubStr(dirName, 1, 4)
        If (prefix = "dist")
            Return prevPath
        If (prefix = "soft") {
            Return path
        }
    }
    ; not found
    Return ""
}

RelativePath(ByRef fullPath, ByRef basePath) {
    ; both fullPath and basePath are absolute paths
    ; return the relative path from basePath to fullPath
    baseLen := StrLen(basePath)
    If (SubStr(fullPath, 1, baseLen) = basePath)
        Return SubStr(fullPath, baseLen + 2) ; +2 = (+1 because offsets are counted from 1) + (+1 to skip the backslash)
    Return ; not a subpath
}

MoveToOld(path) {
    ; given a path like
    ; d:\Distributives\Soft\Archivers Packers\7Zip\7z2408-x64 64-bit x64.exe
    ; move it to d:\Distributives\_old\Soft\Archivers Packers\7Zip\7z2408-x64 64-bit x64.exe
    ; or d:\Distributives\Soft FOSS\Archivers Packers\7-Zip\7-zip.org\a\7z2408-x64.exe
    ; to d:\Distributives\_old\Soft FOSS\Archivers Packers\7-Zip\7-zip.org\a\7z2408-x64.exe
    ; Soft -> _old\Soft
    ; Drivers -> _old\Drivers
    ; Developement -> _old\Developement
    local
    EnvGet baseDistributives, baseDistributives
    Loop Files, %path%
        path := A_LoopFileLongPath
    If (!baseDistributives) {
        baseDistributives := GuessBaseDistributives(path "\..")
        If (!baseDistributives)
            Throw Exception("Cannot guess baseDistributives from path",, path)
    }

    relPath := RelativePath(path, baseDistributives)
    If (!relPath)
        Throw Exception("Path is not a subpath of baseDistributives",, path)
    newPath := baseDistributives "\_old\" relPath
    SplitPath newPath, , newPathDir
    FileCreateDir %newPathDir%
    If (InStr(FileExist(path), "D"))
        FileMoveDir %path%, %newPath%, R
    Else
        FileMove %path%, %newPathDir%\
}
