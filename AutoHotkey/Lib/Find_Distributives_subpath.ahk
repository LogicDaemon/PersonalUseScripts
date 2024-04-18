#NoEnv

Find_Distributives_subpath(ByRef subpath) {
    local
    static baseDirsList := ""
    If (!baseDirsList) {
        baseDirsList := [], baseDirsSet := {}
        distBaseDirsListFileBase := ExpandEnvVars("%LocalAppData%\Scripts\_Distributives.base_dirs")
        distBaseDirsListFileSuffix := ".txt"
        RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
        If (!FileExist(distBaseDirsListFile := distBaseDirsListFileBase "@" hostname distBaseDirsListFileSuffix) )
            distBaseDirsListFile := distBaseDirsListFileBase distBaseDirsListFileSuffix
        If (FileExist(distBaseDirsListFile)) {
            FileRead distBaseDirsList, %distBaseDirsListFile%
        } Else {
            EnvGet USERPROFILE,USERPROFILE
            distBaseDirsList =
            ( LTrim
                D:
                %A_MyDocuments%
                %USERPROFILE%
            )
        }
        Loop Parse, distBaseDirsList, `n, `r
            If (s := Trim(A_LoopField)) {
                basePath := ExpandEnvVars(s)
                ; baseDirsSet is only needed to avoid checking same dir multiple times
                If (!baseDirsSet.HasKey(basePath))
                    baseDirsSet[basePath] := baseDirsList.Push(basePath)
                ; baseDirsList is used to cache _Distributives.base_dirs.txt and avoid reading it multiple times
                ; baseDirsList must be filled in here, so not checking yet for existence of requested path
                ; this is only executed first time function is called
            }
    }
    
    For i, basePath in baseDirsList {
        If (FileExist(res := basePath subpath))
            return res
        If (FileExist(res := basePath "\Distributives\" subpath))
            return res
    }
    Throw Exception("Distributives with subpath not found",, subpath)
}

#include <ExpandEnvVars>
