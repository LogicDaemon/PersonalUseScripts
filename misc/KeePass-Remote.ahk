#NoEnv

EnvGet LocalAppData, LOCALAPPDATA

Loop Read, %LocalAppData%\_sec\KeePassKeyFind.txt
{
    key := FirstMatching(ExpandEnvVars(A_LoopReadLine))
} Until key

nameDB := "Database.kdb"
dirDB := FindDBdir(nameDB)
commandLineParam = "%dirDB%\%nameDB%" -preselect:"%key%"

#include %A_LineFile%\..\KeePass.ahk

ExitApp

FindDBdir(ByRef nameDB) {
    Try dropboxDir := GetDropboxDir()
    Catch e {
        TrayTip % e.Message, % e.What
    }

    For i, dirDB in [dropboxDir "\KeePass", A_MyDocuments "\private\KeePass", A_MyDocuments "\KeePass"]
        If (FileExist(dirDB "\" nameDB))
            return dirDB
}

FirstMatching(paths*) {
    For i, path in paths
        Loop Files, %path%
            return A_LoopFileLongPath
}

#include <GetDropboxDir>
