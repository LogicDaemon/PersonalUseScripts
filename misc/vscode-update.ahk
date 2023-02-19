#NoEnv

If (FileExist(A_ScriptDir "\..\VSCode-win32-x64-*.zip")) {
    distDir = %A_ScriptDir%\..
} Else {
    distDir := Find_Distributives_subpath("Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code")
}
vsCodeDest := ExpandEnvVars("%LocalAppData%\Programs\VS Code")
#include <find7zexe>
updInfo := DownloadVSCode(distDir, vsCodeDest)
updDirOrErrors := UpdateVSCode(distDir, vsCodeDest, updInfo, [distDir "\VSCode_dark_theme.7z"])
If (IsObject(updDirOrErrors)) {
    errorsText := JSON.Dump(updDirOrErrors)
    FileAppend % ObjectToText(updInfo) "`n" errorsText "`n", %A_Temp%\%A_ScriptName%.log
    Run *Open "%A_Temp%\%A_ScriptName%.log"
    Throw Exception("Update errors",, errorsText)
} Else {
    CleanOldInstallations(updDirOrErrors, vsCodeDest)
}
Exit 0

DownloadVSCode(ByRef distDir, ByRef vsCodeDest) {
    global JSON
    verDistFile = %vsCodeDest%.installed.json
    Try {
        lastUpdInfo := LoadJSON(verDistFile), installedDistID := lastUpdInfo.version
    }
    ;ToDo: try downloading from https://update.code.visualstudio.com/latest/win32-x64-user/stable
    ; 1.40.1 8795a9889db74563ddd43eb0a897a2384129a619
    ; 1.40.2 f359dd69833dd8800b54d458f6d37ab7c78df520
    ; 1.52.1 ea3859d4ba2f3e577a159bc91e3074c5d85c0523
    ; 1.73.1 6261075646f055b99068d3688932416f2346dd3b
    ; 1.74.0 5235c6bb189b60b01b1f49062f4ffa42384f8c91
    Loop 2
    {
        updInfoRaw := GetURL("https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/" (installedDistID ? installedDistID : "ea3859d4ba2f3e577a159bc91e3074c5d85c0523"))
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
    updInfo := JSON.Load(updInfoRaw), newVerURL := updInfo.url
    If (!updInfo.version) {
        If (lastUpdInfo.url)
            updInfo := lastUpdInfo ; try re-downloading the missing archive
        Else
            Throw Exception("Version request has not returned GUID",, updInfoRaw)
    }
    dlName := SplitFileNameInUpdInfo(updInfo)
    path := distDir "\" dlName
    ; {"url":"https://az764295.vo.msecnd.net/stable/f359dd69833dd8800b54d458f6d37ab7c78df520/VSCode-win32-x64-1.40.2.zip","name":"1.40.2","version":"f359dd69833dd8800b54d458f6d37ab7c78df520","productVersion":"1.40.2","hash":"7c33d0ec7dec6b23d64bb209316bc07c5ba0ebaf","timestamp":1574693656541,"sha256hash":"1b2311c276cbee310e801b4d6a9e0cd501ee35e66c55db4d728d15a6a4ada033","supportsFastUpdate":true}
    If (FileExist(path) && updInfo.version == installedDistID) {
        updInfo.path := path
        return updInfo
    }
    EnvGet SystemRoot, SystemRoot
    SplitPath dlName,,,, OutNameNoExt
    distPathMask=%distDir%\%OutNameNoExt%.*
    If (distPathArchive := FindArchive(distPathMask)) {
        updInfo.path := distPathArchive
        return updInfo
    }
    tmpDlDir = %A_TEMP%\%A_ScriptName%.tmp
    FileCreateDir %tmpDlDir%
    cmdline = %SystemRoot%\System32\curl.exe -RO -z "%path%" "%newVerURL%"
    RunWait %cmdline%, %tmpDlDir%, Min UseErrorLevel
    If (ErrorLevel) {
        errorMessage = Error %ErrorLevel% downloading URL
        dlscriptf := FileOpen(A_TEMP "\download_vscode.cmd", "w")
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
    FileMove %tmpDlDir%\%dlName%, %path%, 1
    If (ErrorLevel)
        Throw Exception("Failed to move downloaded distributive to its supposed location",, """" tmpDlDir "\" dlName """ to """ path """")
    updInfo.path := path
    return updInfo
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

UpdateVSCode(ByRef distDir, ByRef destDir, ByRef updInfo, additionalArchives) {
    global exe7z, JSON
    errors := {}
    
    If (IsObject(additionalArchives))
        paths := additionalArchives.Clone()
    Else
        paths := []
    paths[paths.MinIndex()-1] := updInfo.path ; distDir "\" SplitFileNameInUpdInfo(updInfo)
    newVerName := updInfo.name
    If (!newVerName)
        Throw Exception("No updated version (updInfo.name) defined",, updInfo)
    For i, v in paths {
        destDirWithVer := destDir "-" newVerName
        If (FileExist(v)) {
            If (FileExist(destDirWithVer "\Code.exe"))
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
