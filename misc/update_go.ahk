#NoEnv
#SingleInstance

#include <find7zexe>

Try {
    goVerURL:="https://go.dev/VERSION?m=text"
    distDir := Find_Distributives_subpath("Developement\go")
    goVersion := GetURL(goVerURL)
    If (!goVersion)
        Throw Exception("Error retrieving go version",, goVerURL)
    
    Loop Parse, goVersion, `n, `r
    {
        goVer := Trim(A_LoopField, "`r`n `t")
        break
    }
    If (!goVer)
        Throw Exception("Error parsing go version",, goVersion)
    
    Try {
        f := FileOpen(distDir "\VERSION", "r")
        prevVer := f.ReadLine()
    }
    Try {
        f.Close()
    }
    If (prevVer != goVer) {
        FileMove %distDir%\VERSION, %distDir%\VERSION.bak, 1
        f := FileOpen(distDir "\VERSION", "w")
        f.Write(goVersion)
        f.Close()
    }
    
    For i, ext in ["7z", "zip"] { ; zip must be the last
        goDistFName := goVer ".windows-amd64." ext
        If (FileExist(distDir "\" goDistFName)) {
            distExists := True
            break
        }
    }

    If (!distExists) {
        tempDir=%distDir%\temp
        FileCreateDir %tempDir%
        dlURL := "https://golang.org/dl/" goDistFName
        ;-z doesn't work with the go distributive server
        ;timeCond := FileExist(distDir "\" goDistFName) ? "-z """ distDir "\" goDistFName """" : ""
        curlcmd = curl.exe -RJOL %timeCond% "%dlURL%"
        RunWait %curlcmd%, %tempDir%, Min
        If (ErrorLevel)
            Throw Exception(curlcmd,, ErrorLevel)
        FileGetSize distSize, %tempDir%\%goDistFName%
        If (!distSize) {
            Try {
                FileDelete %tempDir%\%goDistFName%
            }
            FileAppend %A_Now% %curlcmd%`n, %A_Temp%\%A_ScriptName%.log, CP1
            Throw Exception("0-sized distributive downloaded",, dlURL)
        }
        
        RunWait %comspec% /C ""%A_ScriptDir%\repack_to_7z.cmd" /NK "%tempDir%\%goDistFName%"", %tempDir%, Min UseErrorLevel
        If (!ErrorLevel) {
            ;SplitPath goDistFName, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
            SplitPath goDistFName, , , , goDistFNameNoExt
            goDistFName := goDistFNameNoExt ".7z"
        }
        
        FileMove %tempDir%\%goDistFName%, %distDir%\%goDistFName%
        Try {
            FileRemoveDir %tempDir%
        }
    }


    destDir := ExpandEnvVars("%LocalAppData%\Programs") "\go"
    If (IsObject(InstallUpdate(distDir, goDistFName, destDir, SubStr(goVer, 1, 2) == "go" ? SubStr(goVer, 3) : goVer, "go", "bin\go.exe"))) {
        errLog = %A_Temp%\%A_ScriptName%.log
        FileAppend % ObjectToText(updDirOrErrors) "`n", %errLog%
        Throw Exception("Update errors. Error log is in ""%TEMP%\" A_ScriptName ".log""" ,, ObjectToText(updDirOrErrors))
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
    
    distSubdir := BackslashPrefixed(distSubdir)
    destLinkDir := destDirWithVer . distSubdir
    
    checkPath := BackslashPrefixed(checkPath)
    destCheckPath := destLinkDir . checkPath
    
    If (!FileExist(distPath))
        Throw Exception("Distributive does not exist",, distPath)
    If (!FileExist(destCheckPath)) {
        ;If FileExist(distPath ".tmp")
        ;    FileRemoveDir %distPath%.tmp, 1
        cmdexec = "%exe7z%" x -aoa -o"%destDirWithVer%" -- "%distPath%"
        RunWait %cmdexec%,, Min UseErrorLevel
        If (ErrorLevel) {
            errors["7-Zip"] := savedErr := ErrorLevel
            If (savedErr>=2) {
                ;Try {
                ;    FileRemoveDir %distPath%.tmp, 1
                ;}
                FileAppend %A_Now% %cmdexec%`n, %A_Temp%\%A_ScriptName%.log, CP1
                Throw Exception("7-Zip unpacking error",, ErrorLevel "`n""" distPath ".tmp""")
            }
        }
        ;FileMoveDir %distPath%.tmp, %distPath%, R
    }
    Run compact.exe /C /EXE:LZX /S, %destLinkDir%, Min UseErrorLevel
    RunWait %comspec% /C "RD "%destDir%" & MKLINK /J "%destDir%" "%destLinkDir%"", %destLinkDir%\.., Min UseErrorLevel
    If (ErrorLevel)
        errors["MKLINK"] := ErrorLevel
    ; Cleanup the old versions
    If (!errors.Count()) {
        Loop Files, %destDir%-*, D
        {
            checkFullPath := A_LoopFileFullPath . distSubdir . checkPath
            If ( A_LoopFileFullPath != destDirWithVer
                && FileExist(A_LoopFileFullPath . distSubdir . checkPath) ) {
                ; MsgBox Removing %checkFullPath% and then %A_LoopFileFullPath%
                Try {
                    FileDelete %checkFullPath%
                    ; continues only if the checked path was successfully deleted
                    FileRemoveDir %A_LoopFileFullPath%, 1
                }
            }
        }
    }
    return errors.Count() ? errors : destDirWithVer
}

BackslashPrefixed(str) {
    return (str && SubStr(str, 1, 1) != "\") ? "\" str : str
}

#include <GetURL>
