#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (A_ScriptFullPath == A_LineFile) {
    Loop % A_Args.Length()
        MoveToOld(A_Args[A_Index])
    ExitApp
}

MoveToOld(path) {
    ; given a path like
    ; d:\Distributives\Soft\Archivers Packers\7Zip\7z2408-x64 64-bit x64.exe
    ; move it to d:\Distributives\Soft_old\Archivers Packers\7Zip\7z2408-x64 64-bit x64.exe
    ; or d:\Distributives\Soft FOSS\Archivers Packers\7-Zip\7-zip.org\a\7z2408-x64.exe
    ; to d:\Distributives\Soft_old\Archivers Packers\7-Zip\7-zip.org\a\7z2408-x64.exe
    ; Soft -> Soft_old
    ; Drivers -> Drivers_old
    ; Developement -> Developement_old
    local
    STABLE_PREFIX := "Distributives\"

    distOffset := InStr(path, STABLE_PREFIX)
    If (!distOffset)
        Throw Exception("Path does not contain """ STABLE_PREFIX """", , path)

    modOffset := distOffset + StrLen(STABLE_PREFIX)
    stablePrefix := SubStr(path, 1, modOffset - 1)

    subPathOffset := InStr(path, "\", true, modOffset + 1)
    subPath := SubStr(path, subPathOffset + 1)

    modName := SubStr(path, modOffset, subPathOffset - modOffset)
    If (SubStr(modName, -4) == "_old")
        Throw Exception("Path already contains ""_old""", , path)

    modPrefixLen := InStr(modName, " ", true)
    moddedName := (modPrefixLen ? SubStr(modName, 1, modPrefixLen - 1) : modName) . "_old"

    newPath := stablePrefix . moddedName "\" subPath
    SplitPath newPath, , newPathDir
    FileCreateDir %newPathDir%
    If (InStr(FileExist(path), "D"))
        FileMoveDir %path%, %newPath%, R
    Else
        FileMove %path%, %newPathDir%\
}
