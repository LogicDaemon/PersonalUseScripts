FindKeePassExe(KeePassExeName := "KeePass.exe", keepassPaths := "") {
    Local
    Static KeePassExePath := ""
    If (KeePassExePath)
        return KeePassExePath
    EnvGet LocalAppData,LOCALAPPDATA
    If (keepassPaths=="") {
        keepassPaths := [ LocalAppData "\Programs\KeePass\" KeePassExeName
                        , LocalAppData "\Programs\KeePass Password Safe\" KeePassExeName
                        , A_ProgramFiles "\KeePass Password Safe\" KeePassExeName ]
        EnvGet lProgramFiles,ProgramFiles(x86)
        If (lProgramFiles)
            keepassPaths.Push(lProgramFiles "\KeePass Password Safe\" KeePassExeName)
    }
    If (!(KeePassExePath := FirstExisting( keepassPaths* )))
        Throw Exception("KeePass.exe not found")
    Return KeePassExePath
}
