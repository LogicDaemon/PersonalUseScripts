#NoEnv

Find_Distributives_subpath(ByRef subpath) {
    local
    static baseDirsList := ""
    If (!baseDirsList) {
        baseDirsList := [], baseDirsSet := {}
        distBaseDirsListFile := ExpandEnvVars("%LocalAppData%\Scripts\_Distributives.base_dirs.txt")
        If (FileExist(distBaseDirsListFile)) {
            FileRead distBaseDirsList, %distBaseDirsListFile%
        }
        distBaseDirsList =
        ( LTrim
            %distBaseDirsList%
            D:
            X:
            %A_MyDocuments%
        )
        Loop Parse, distBaseDirsList, `n, `r
            If (s := Trim(A_LoopField)) {
                basePath := ExpandEnvVars(s)
                If (!baseDirsSet.HasKey(basePath))
                    baseDirsSet[basePath] := baseDirsList.Push(basePath)
            }
    }
    
    For i, basePath in baseDirsList {
        If (FileExist(res := basePath "\Distributives\" subpath))
            return res
    }
    Throw Exception("Distributives with subpath not found",, subpath)
}
