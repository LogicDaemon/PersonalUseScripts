﻿#NoEnv
#SingleInstance
#Include %A_ScriptDir%\vscode-update.ahk

If (A_ScriptFullPath == A_LineFile) {
    DownloadAndUpdateVSCodeInsiders()
    Exit 0
}

DownloadAndUpdateVSCodeInsiders(ByRef distDir := "", ByRef vsCodeDest := "", insiders := True) {
    local
    global JSON
    nameSuffix := insiders ? " Insiders" : ""
    If (!distDir) {
        If (FileExist(A_ScriptDir "\..\VSCode-win32-x64-*.zip")) {
            distDir := A_ScriptDir "\.."
        } Else {
            distDir := Find_Distributives_subpath("Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code" nameSuffix)
        }
    }
    If (!vsCodeDest)
        vsCodeDest := ExpandEnvVars("%LocalAppData%\Programs\VS Code" nameSuffix)
    updInfo := DownloadVSCodeInsiders(distDir, vsCodeDest, insiders)
    updDirOrErrors := UpdateVSCode(vsCodeDest, updInfo) ; , [distDir "\VSCode_dark_theme.7z"]
    If (IsObject(updDirOrErrors)) {
        errorsText := JSON.Dump(updDirOrErrors)
        FileAppend % ObjectToText(updInfo) "`n" errorsText "`n", %A_Temp%\%A_ScriptName%.log
        Run *Open "%A_Temp%\%A_ScriptName%.log"
        Throw Exception("Update errors",, errorsText)
    } Else {
        RunWait %comspec% /C "MKLINK /H "%vsCodeDest%\code-insiders.exe" "%vsCodeDest%\Code - Insiders.exe"", %vsCodeDest%, Min
        CleanOldInstallations(updDirOrErrors, vsCodeDest)
        DedupInstallations(vsCodeDest)
    }
}

DownloadVSCodeInsiders(ByRef distDir, ByRef vsCodeDest, insiders := True) {
    local
    global exe7z, JSON
    urlSuffixChannel := insiders ? "insider" : "stable"
    urlSuffixArch := "win32-x64"

    verDistFile = %vsCodeDest%.installed.json
    Try {
        lastUpdInfo := LoadJSON(verDistFile), installedDistID := lastUpdInfo.version
    }
    Loop 2
    {
        ; https://update.code.visualstudio.com/api/update/win32-x64-archive/insider/2946b1ee55db1d406526d3fd1df49250b2f8322d
        url := "https://update.code.visualstudio.com/api/update/" urlSuffixArch "-archive/" urlSuffixChannel "/" (installedDistID ? installedDistID : "8795a9889db74563ddd43eb0a897a2384129a619")
        updInfoRaw := GetURL(url)
        If (updInfoRaw)
            break
        If (!installedDistID)
            Throw Exception("Neither the current version info was received from the update server, nor a previous versions is available")
        If (lastUpdInfo.path && FileExist(lastUpdInfo.path))
            Return lastUpdInfo
        If (existingArchive := FindArchive(distPathMask)) {
            lastUpdInfo.path := existingArchive
            Return lastUpdInfo
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
        SplitPath % updInfo.url, dlName,, dlExt, dlNameNoExt
        If (insiders) {
            path := distDir "\" dlNameNoExt "-" updInfo.version "." dlExt
                , distPathMask := distDir "\" dlNameNoExt "-" updInfo.version ".*"
        } Else {
            path := distDir "\" dlName
                , distPathMask := distDir "\" dlNameNoExt ".*"
        }
        ; stable:
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
        ; insiders:
        ; https://update.code.visualstudio.com/api/update/win32-x64-archive/insider/2946b1ee55db1d406526d3fd1df49250b2f8322d
        ; {
        ;  "url":               "https://az764295.vo.msecnd.net/insider/2d416df5f00253f5ebd60d2f08508a440747fd8d/VSCode-win32-x64-1.79.0-insider.zip",
        ;  "name":              "1.79.0-insider",
        ;  "version":           "2d416df5f00253f5ebd60d2f08508a440747fd8d",
        ;  "productVersion":    "1.79.0-insider",
        ;  "hash":              "376f340d5ecb36a93dc8c156e1ab1363f500c048",
        ;  "timestamp":          1684473457746,
        ;  "sha256hash":        "c9960cc91118c91e73d469b840de67da74980dc3840bd530c7c5fadce1c88765",
        ;  "supportsFastUpdate": true
        ; }
        If (FileExist(path) && updInfo.version == installedDistID) {
            updInfo.path := path
            Return updInfo
        }
        If (distPathArchive := FindArchive(distPathMask)) {
            updInfo.path := distPathArchive
            Return updInfo
        }
    }
    EnvGet SystemRoot, SystemRoot
    If (newVerURL) { ; newVerURL is only available when updInfoRaw is known; in these cases, path will also be defined
        pathtmp := path ".tmp"
        ; -O remote name overrides -o
        cmdline = %SystemRoot%\System32\curl.exe -R -z "%path%" -o "%pathtmp%" -- "%newVerURL%"
    } Else {
        ; Try https://update.code.visualstudio.com/latest/win32-x64-user/$urlSuffixChannel
        newVerURL := "https://update.code.visualstudio.com/latest/" urlSuffixArch "-user/" urlSuffixChannel
        cmdline = %SystemRoot%\System32\curl.exe -RO -- "%newVerURL%"
    }
    FileDelete %distDir%\*.tmp
    RunWait %cmdline%, %distDir%, Min UseErrorLevel
    If (ErrorLevel) {
        errorMessage = Error %ErrorLevel% downloading URL
    } Else {
        If (path) {
            If (!FileExist(pathtmp)) {
                ; Assume curl -z found that current file is fresh enough
                pathtmp := ""
            }
        } Else {
            pathtmp := FirstExistingFilePath(distDir "\*.tmp")
            expectedDistNamePrefix := insiders ? "VSCode-" urlSuffixArch "-" : ""
            If (pathtmp) {
                path := SubStr(pathtmp, 1, -4)
                If (insiders) {
                    SplitPath path, latestDistFileName
                    If (StartsWith(latestDistFileName, expectedDistNamePrefix))
                        Loop Files, %distDir%\%expectedDistNamePrefix%*.*
                            If (A_LoopFileName != latestDistFileName)
                                FileDelete %A_LoopFileFullPath%
                }
            } Else {
                ; VSCode-win32-x64-1.79.0-insider-2dfb838f494f035099e999f0cd0eff5f1f488a30.zip
                Loop Files, %distDir%\%expectedDistNamePrefix%*.*
                {
                    If A_LoopFileExt not in zip,7z
                        Continue
                    If (A_LoopFileTimeModified > latestTime) {
                        If (insiders)
                            FileDelete %path%
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
                    Throw Exception("Rename failed",, """" pathtmp """ to """ path """")
            }
            If (!IsObject(updInfo)) {
                ; resources\app\product.json in the archive contains the build info,
                ; from where "commit" matches updInfo.version
                ; But the archive is not yet unpacked at this stage
                tmpDir := A_Temp "\" A_Scriptname ".tmp"
                fullCmd = %exe7z% x -aoa -y -o"%tmpDir%" -- "%path%" "resources\app\product.json"
                RunWait %fullCmd%,, Min UseErrorLevel
                If (ErrorLevel)
                    Throw Exception("Failed to unpack resources\app\product.json from """ path """",, fullCmd)
                productInfoPath := tmpDir "\resources\app\product.json"
                productInfo := LoadJSON(productInfoPath)
                If (!IsObject(productInfo))
                    Throw Exception("Product info cannot be read",, productInfoPath)
                FileRemoveDir %tmpDir%, 1
                updInfo := {"version": productInfo.commit}
            }
            updInfo.path := path
            Return updInfo
        }
    }

    If (FileExist(distDir "\.Distributives_Update_Run.*.cmd")) {
        Loop Files, %distDir%\.Distributives_Update_Run.*.cmd
        {
            RunWait %comspec% /C "%A_LoopFileFullPath%", %distDir%, Min UseErrorLevel
            If (distPathArchive := FindArchive(distPathMask)) {
                updInfo.path := distPathArchive
                Return updInfo
            }
        }
    }

    If (dlNameNoExt) {
        dlscriptf := FileOpen(distDir "\download_" dlNameNoExt (newVerURL ? "-" updInfo.version : "") "." dlExt ".cmd", "w", CP866)
        dlscript =
        (LTrim
            @(REM coding:CP866
            PUSHD "%tmpDlDir%" || EXIT /B
            %cmdline%
            `)
        )
        dlscriptf.WriteLine(dlscript)
        dlscriptf.Close()
    }
    Throw Exception(errorMessage,, newVerURL)
}
