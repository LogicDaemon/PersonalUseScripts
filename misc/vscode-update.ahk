#NoEnv
#include <find7zexe>

If (A_ScriptFullPath == A_LineFile) {
    DownloadAndUpdateVSCode()
    Exit 0
}

DownloadAndUpdateVSCode(ByRef distDir := "", ByRef vsCodeDest := "", ByRef urlSuffixChannel := "", ByRef urlSuffixArch := "") {
    If (!distDir) {
        If (FileExist(A_ScriptDir "\..\VSCode-win32-x64-*.zip")) {
            distDir = A_ScriptDir "\.."
        } Else {
            distDir := Find_Distributives_subpath("Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code")
        }
    }
    If (!vsCodeDest)
        vsCodeDest := ExpandEnvVars("%LocalAppData%\Programs\VS Code")
    updInfo := DownloadVSCode(distDir, vsCodeDest, urlSuffixChannel, urlSuffixArch)
    updDirOrErrors := UpdateVSCode(vsCodeDest, updInfo, [distDir "\VSCode_dark_theme.7z"])
    If (IsObject(updDirOrErrors)) {
        errorsText := JSON.Dump(updDirOrErrors)
        FileAppend % ObjectToText(updInfo) "`n" errorsText "`n", %A_Temp%\%A_ScriptName%.log
        Run *Open "%A_Temp%\%A_ScriptName%.log"
        Throw Exception("Update errors",, errorsText)
    } Else {
        CleanOldInstallations(updDirOrErrors, vsCodeDest)
    }
}

DownloadVSCode(ByRef distDir, ByRef vsCodeDest, ByRef urlSuffixChannel := "", ByRef urlSuffixArch := "") {
    global JSON
    If (!urlSuffixChannel)
        urlSuffixChannel := "stable"
    If (!urlSuffixArch)
        urlSuffixArch := "win32-x64"

    verDistFile = %vsCodeDest%.installed.json
    Try {
        lastUpdInfo := LoadJSON(verDistFile), installedDistID := lastUpdInfo.version
    }
    ; 1.40.1 8795a9889db74563ddd43eb0a897a2384129a619
    ; 1.40.2 f359dd69833dd8800b54d458f6d37ab7c78df520
    ; 1.52.1 ea3859d4ba2f3e577a159bc91e3074c5d85c0523
    ; 1.73.1 6261075646f055b99068d3688932416f2346dd3b
    ; 1.74.0 5235c6bb189b60b01b1f49062f4ffa42384f8c91
    ; 1.78.2 b3e4e68a0bc097f0ae7907b217c1119af9e03435
    Loop 2
    {
        url := "https://update.code.visualstudio.com/api/update/" urlSuffixArch "-archive/" urlSuffixChannel "/" (installedDistID ? installedDistID : "8795a9889db74563ddd43eb0a897a2384129a619")
        updInfoRaw := GetURL(url)
        ; https://update.code.visualstudio.com/api/update/win32-x64-archive/insider/2946b1ee55db1d406526d3fd1df49250b2f8322d
        If (updInfoRaw)
            break
        If (!installedDistID)
            Throw Exception("Neither the current version info was received from the update server, nor a previous versions is available")
        If (lastUpdInfo.path && FileExist(lastUpdInfo.path))
            return lastUpdInfo
        If (existingArchive := FindArchive(distPathMask)) {
            lastUpdInfo.path := existingArchive
            return lastUpdInfo
        }
        installedDistID := ""
    }
    If (updInfoRaw) {
        updInfo := JSON.Load(updInfoRaw), newVerURL := updInfo.url
        If (!updInfo.version) {
            If (lastUpdInfo.url)
                updInfo := lastUpdInfo ; try re-downloading the missing archive
            Else
                Throw Exception("Version request has not returned GUID",, updInfoRaw)
        }
        SplitPath % updInfo.url, dlName,,, OutNameNoExt
        path         := distDir "\" dlName
        distPathMask := distDir "\" OutNameNoExt ".*"
        ; {
        ;  "url":                   "https://az764295.vo.msecnd.net/stable/f359dd69833dd8800b54d458f6d37ab7c78df520/VSCode-win32-x64-1.40.2.zip",
        ;  "version":               "f359dd69833dd8800b54d458f6d37ab7c78df520",
        ;  "hash":                  "7c33d0ec7dec6b23d64bb209316bc07c5ba0ebaf",
        ;  "sha256hash":            "1b2311c276cbee310e801b4d6a9e0cd501ee35e66c55db4d728d15a6a4ada033",
        ;  "name":                  "1.40.2",
        ;  "productVersion":        "1.40.2",
        ;  "timestamp":             1574693656541,
        ;  "supportsFastUpdate":    true
        ; }
        If (FileExist(path) && updInfo.version == installedDistID) {
            updInfo.path := path
            return updInfo
        }
        If (distPathArchive := FindArchive(distPathMask)) {
            updInfo.path := distPathArchive
            return updInfo
        }
    }
    EnvGet SystemRoot, SystemRoot
    If (newVerURL) {
        ; -O remote name overrides -o
        cmdline = %SystemRoot%\System32\curl.exe -R -z "%path%" -o "%path%.tmp" -- "%newVerURL%"
    } Else {
        ; Try https://update.code.visualstudio.com/latest/win32-x64-user/stable
        newVerURL := "https://update.code.visualstudio.com/latest/" urlSuffixArch "-user/" urlSuffixChannel
        cmdline = %SystemRoot%\System32\curl.exe -RO -- "%newVerURL%"
    }
    FileDelete %distDir%\*.tmp
    RunWait %cmdline%, %distDir%, Min UseErrorLevel
    If (ErrorLevel) {
        errorMessage = Error %ErrorLevel% downloading URL
    } Else {
        If (path) {
            pathtmp := path ".tmp"
            If (!FileExist(pathtmp)) {
                ; Assume curl -z found that current file is fresh enough
                pathtmp := ""
            }
        } Else {
            pathtmp := FirstExisting(distDir "\*.tmp")
            If (pathtmp) {
                path := SubStr(pathtmp, 1, -4)
            } Else {
                Loop Files, %distDir%\*.*
                {
                    If A_LoopFileExt not in zip,7z
                        Continue
                    If (A_LoopFileTimeModified > latestTime) {
                        latestTime := A_LoopFileTimeModified
                        , path := A_LoopFileFullPath
                    }
                }
            }
        }
        If (path) {
            If (pathtmp) {
                FileMove %pathtmp%, %path%, 1
                If (ErrorLevel)
                    Throw Exception("Rename failed",, """" %path%.tmp """ to """ path """")
            }
            updInfo.path := path
            return updInfo
        }
    }
    
    If (FileExist(distDir "\.Distributives_Update_Run.*.cmd")) {
        Loop Files, %distDir%\.Distributives_Update_Run.*.cmd
        {
            RunWait %comspec% /C "%A_LoopFileFullPath%", %distDir%, Min UseErrorLevel
            If (distPathArchive := FindArchive(distPathMask)) {
                updInfo.path := distPathArchive
                return updInfo
            }
        }
    }

    dlscriptf := FileOpen(distDir "\download_" dlNameNoExt "." dlExt ".cmd", "w", CP866)
    dlscript =
        (LTrim
        @(REM coding:CP866
        PUSHD "%tmpDlDir%" || EXIT /B
        %cmdline%
        `)
        )
    dlscriptf.WriteLine(dlscript)
    dlscriptf.Close()
    Throw Exception(errorMessage,, newVerURL)
}

FindArchive(mask) {
    global exe7z
    
    Loop Files, %mask%
    {
        RunWait "%exe7z%" t "%A_LoopFileFullPath%",, Min UseErrorLevel
        If (!ErrorLevel)
            return A_LoopFileFullPath
    }
}

UpdateVSCode(ByRef destDir, ByRef updInfo, additionalArchives := "") {
    global exe7z, JSON
    errors := {}

    If (additionalArchives)
        paths := IsObject(additionalArchives) ? additionalArchives.Clone() : [paths]
    Else
        paths := []

    updInfo_path := updInfo.path
    paths[paths.MinIndex()-1] := updInfo_path
    ; SplitPath InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath updInfo_path,            ,       ,             , newVerName
    If (!newVerName)
        Throw Exception("No updated version (empty filename in updInfo.path)",, updInfo)
    For i, prefix in ["VSCode-", "win32-x64-"]
    If (StartsWith(newVerName, prefix))
        newVerName := SubStr(newVerName, StrLen(prefix)+1)
    For i, v in paths {
        destDirWithVer := destDir "-" newVerName
        If (FileExist(v)) {
            If (FileExist(destDirWithVer "\Code*.exe"))
                continue
            RunWait "%exe7z%" x -aoa -o"%destDirWithVer%" -- "%v%",, Min UseErrorLevel
            If (ErrorLevel)
                errors[v] := "7-zip error code: " ErrorLevel
        } Else If (i<1) {
            errors[v] := "Does not exist"
        }
    }
    RunWait %comspec% /C "RD "%destDir%" 2>NUL & MKLINK /J "%destDir%" "%destDirWithVer%"",, Min
    If (ErrorLevel)
        errors["MKLINK"] := ErrorLevel
    If (!errors.Count()) {
        verDistFile = %destDir%.installed.json
        f := FileOpen(verDistFile, "w")
        f.Write(JSON.Dump(updInfo))
        f.Close()
    }
    return errors.Count() ? errors : destDirWithVer
}

CleanOldInstallations(ByRef newVerDir, ByRef destDir) {
    Loop Files, %destDir%-*, D
    {
        If ( A_LoopFileFullPath <> newVerDir
            && FileExist(mainexe := A_LoopFileFullPath "\Code.exe")) {
            FileDelete %mainexe%
            If (!ErrorLevel)
                FileRemoveDir %A_LoopFileFullPath%, 1
        }
    }
}

SplitFileNameInUpdInfo(updInfo) {
    local
    SplitPath % updInfo.url, dlName
    return dlName
}

LoadJSON(ByRef path) {
    local
    global JSON
    
    FileRead data, %path%
    If (data)
        return JSON.Load(data)
}

#include <GetURL>
#include <JSON>
