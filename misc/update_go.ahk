#NoEnv
#SingleInstance

Try {
    distDir := Find_Distributives_subpath("Developement\go")
    goVer := GetURL("https://golang.org/VERSION?m=text")
    If (!goVer) {
        MsgBox Go version is not retrieved from https://golang.org/VERSION?m=text, instead got "%goVer%"
        ExitApp 1
    }
    goDistFName := goVer ".windows-amd64.zip"
    dlURL := "https://golang.org/dl/" goDistFName
    timeCond := FileExist(distDir "\" goDistFName) ? "-z """ goDistFName """" : ""
    RunWait curl.exe -RJOL %timeCond% "%dlURL%", %distDir%, Min UseErrorLevel

    #include <find7zexe>

    destDir := ExpandEnvVars("%LocalAppData%\Programs") "\go"
    If (IsObject(InstallUpdate(distDir, goDistFName, destDir, SubStr(goVer, 1, 2) == "go" ? SubStr(goVer, 3) : goVer, "go", "bin\go.exe"))) {
        FileAppend % ObjectToText(updDirOrErrors) "`n", %A_Temp%\%A_ScriptName%.log
        Throw Exception("Update errors",, ObjectToText(updDirOrErrors))
    }
} Catch e {
    Throw e
}
Exit 0

InstallUpdate( ByRef distDir
             , ByRef distFName
             , ByRef destDir
             , ByRef ver
             , distSubdir := ""
             , checkPath := "" ) {
    global exe7z
    errors := {}
    
    distPath := distDir "\" distFName
    destDirWithVer := destDir "-" ver
    distSubdir := BackslashPrefix(distSubdir)
    checkPath := BackslashPrefix(checkPath)
    destLinkDir := destDirWithVer . (distSubdir ? "\" distSubdir : "")
    destCheckPath := destLinkDir . (checkPath ? "\" checkPath : "")
    If (!FileExist(distPath))
        Throw Exception("Distributive does not exist",, distPath)
    If (!FileExist(destCheckPath)) {
        RunWait "%exe7z%" x -aoa -o"%destDirWithVer%" -- "%distPath%",, Min UseErrorLevel
        If (ErrorLevel) {
            If (ErrorLevel>1)
                Throw Exception("Unpacking error from 7-Zip",, ErrorLevel)
            errors[v] := ErrorLevel
        }
    }
    RunWait %comspec% /C "RD "%destDir%" & MKLINK /J "%destDir%" "%destLinkDir%"",, Min
    If (ErrorLevel)
        errors["MKLINK"] := ErrorLevel
    If (!errors.Count()) {
        Loop Files, %destDir%-*, D
        {
            If ( A_LoopFileFullPath != destLinkDir && FileExist(A_LoopFileFullPath . distSubdir . checkPath) ) {
                Try {
                    FileDelete %mainexe%
                    ; continues only if main exe was successfully deleted
                    FileRemoveDir %A_LoopFileFullPath%, 1
                }
            }
        }
    }
    return errors.Count() ? errors : destDirWithVer
}

BackslashPrefix(str) {
    return (str && SubStr(str, 1, 1) != "\") ? "\" str : str
}

#include <GetURL>
