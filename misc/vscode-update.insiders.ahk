#NoEnv
#include %A_ScriptDir%\vscode-update.ahk

If (FileExist(A_ScriptDir "\..\VSCode-win32-x64-*.zip")) {
    distDir := A_ScriptDir "\.."
} Else {
    distDir := Find_Distributives_subpath("Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code Insiders")
}
vsCodeDest := ExpandEnvVars("%LocalAppData%\Programs\VS Code Insiders")

updInfo := DownloadVSCodeInsiders(distDir, vsCodeDest, urlSuffixChannel, urlSuffixArch)
updDirOrErrors := UpdateVSCode(vsCodeDest, updInfo)
If (IsObject(updDirOrErrors)) {
    errorsText := JSON.Dump(updDirOrErrors)
    FileAppend % ObjectToText(updInfo) "`n" errorsText "`n", %A_Temp%\%A_ScriptName%.log
    Run *Open "%A_Temp%\%A_ScriptName%.log"
    Throw Exception("Update errors",, errorsText)
} Else {
    CleanOldInstallations(updDirOrErrors, vsCodeDest)
}

DownloadVSCodeInsiders(ByRef distDir, ByRef vsCodeDest, ByRef urlSuffixChannel := "", ByRef urlSuffixArch := "") {
    global exe7z
    If (!urlSuffixChannel)
        urlSuffixChannel := "insider"
    If (!urlSuffixArch)
        urlSuffixArch := "win32-x64"

    verDistFile = %vsCodeDest%.installed.json
    Try {
        lastUpdInfo := LoadJSON(verDistFile), installedDistID := lastUpdInfo.version
    }
    url := "https://update.code.visualstudio.com/api/update/" urlSuffixArch "-archive/" urlSuffixChannel "/" (installedDistID ? installedDistID : "8795a9889db74563ddd43eb0a897a2384129a619")
    ; https://update.code.visualstudio.com/api/update/win32-x64-archive/insider/2946b1ee55db1d406526d3fd1df49250b2f8322d
    updInfoRaw := GetURL(url)
    ; Don't, since the version name does not change as often as updates appear
    ; If (lastUpdInfo.path && FileExist(lastUpdInfo.path))
    ;     return lastUpdInfo
    ; If (existingArchive := FindArchive(distPathMask)) {
    ;     lastUpdInfo.path := existingArchive
    ;     return lastUpdInfo
    ; }
    If (updInfoRaw) {
        updInfo := JSON.Load(updInfoRaw), newVerURL := updInfo.url
        If (!updInfo.version) {
            If (lastUpdInfo.url)
                updInfo := lastUpdInfo ; try re-downloading the missing archive
        Else
            Throw Exception("Version request has not returned GUID",, updInfoRaw)
        }
        if (installedDistID == updInfo.version)
            return lastUpdInfo
        SplitPath % updInfo.url, dlName,, dlExt, dlNameNoExt
        path           := distDir "\" dlNameNoExt "-" updInfo.version "." dlExt
        distPathMask   := distDir "\" dlNameNoExt "-" updInfo.version ".*"
        distPathScript := distDir "\" dlNameNoExt ".*"
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
        ; Try https://update.code.visualstudio.com/latest/win32-x64-user/insider
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
            If (!IsObject(updInfo)) {
                ; resources\app\product.json in the archive contains the build info,
                ; from where "commit" matches updInfo.version
                ; But the archive is not yet unpacked at this stage
                tmpDir := A_Temp "\" A_Scriptname ".tmp"
                RunWait %exe7z% x -aoa -y -o"%tmpDir%" -- "%path%" "resources\app\product.json",, Min UseErrorLevel
                If (ErrorLevel)
                    Throw Exception("Failed to unpack resources\app\product.json",, path)
                productInfoPath := tmpDir "\resources\app\product.json"
                productInfo := LoadJSON(productInfoPath)
                If (!IsObject(productInfo))
                    Throw Exception("Product info cannot be read",, productInfoPath)
                FileRemoveDir %tmpDir%, 1
                updInfo := {"version": productInfo.commit}
            }
            updInfo.path := path
            return updInfo
        }
    }

    If (FileExist(distDir "\.Distributives_Update_Run.*.cmd")) {
        Loop Files, %distDir%\.Distributives_Update_Run.*.cmd
        {
            RunWait %comspec% /C "%A_LoopFileFullPath%", %distDir%, Min UseErrorLevel
            If (distPathArchive := FindArchive(distPathScript)) {
                updInfo.path := distPathArchive
                return updInfo
            }
        }
    }

    dlscriptf := FileOpen(distDir "\download_" dlNameNoExt "-" updInfo.version "." dlExt ".cmd", "w", CP866)
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