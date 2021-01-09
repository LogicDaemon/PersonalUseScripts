#NoEnv

Try {
    distDir := Find_Distributives_subpath("Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code")
    updInfo := DownloadVSCode(distDir)
    #include <find7zexe>
    UpdateVSCode(distDir, ExpandEnvVars("%LocalAppData%\Programs") "\VS Code", updInfo, [distDir "\VSCode_dark_theme.7z"])
} catch e {
    Throw e
}
Exit 0

DownloadVSCode(ByRef distDir) {
    local
    global JSON
    verDistFile = %distDir%\lastID.txt
    lastUpdCheck := LoadJSON(verDistFile)
    lastDistID := lastUpdCheck.version
    updCheckRaw := GetURL("https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/" (lastDistID ? lastDistID : "8795a9889db74563ddd43eb0a897a2384129a619")) ; 1.40.1
    ;"ea3859d4ba2f3e577a159bc91e3074c5d85c0523" ; 1.52.1
    If (updCheckRaw) {
        updCheck := JSON.Load(updCheckRaw), newVerURL := updCheck.url
        If (!updCheck.version)
            Throw Exception("Version request has not returned GUID",, updCheckRaw)
        dlName := SplitFileNameInUpdCheck(updCheck)
        ; {"url":"https://az764295.vo.msecnd.net/stable/f359dd69833dd8800b54d458f6d37ab7c78df520/VSCode-win32-x64-1.40.2.zip","name":"1.40.2","version":"f359dd69833dd8800b54d458f6d37ab7c78df520","productVersion":"1.40.2","hash":"7c33d0ec7dec6b23d64bb209316bc07c5ba0ebaf","timestamp":1574693656541,"sha256hash":"1b2311c276cbee310e801b4d6a9e0cd501ee35e66c55db4d728d15a6a4ada033","supportsFastUpdate":true}
        If (updCheck.version != lastDistID) {
            EnvGet SystemRoot, SystemRoot
            RunWait %SystemRoot%\System32\curl.exe -RO -z "%distDir%\%dlName%" "%newVerURL%", %distDir%, Min UseErrorLevel
            
            f := FileOpen(verDistFile, "w"), f.Write(updCheckRaw), f.Close()
        }
        return updCheck
    } Else {
        return lastUpdCheck
    }
}

UpdateVSCode(ByRef distDir, ByRef destDir, ByRef updInfo, additionalArchives) {
    local
    global exe7z, JSON
    errors := []
    
    If (IsObject(additionalArchives))
        paths := additionalArchives.Clone()
    Else
        paths := []
    paths[paths.MinIndex()-1] := distDir "\" SplitFileNameInUpdCheck(updInfo)
    For i, v in paths {
        If (FileExist(v)) {
            RunWait "%exe7z%" x -aoa -o"%destDir%.%newVerName%" -- "%v%",, Min
            If (ErrorLevel)
                errors[v] := ErrorLevel
        } Else If (i<1) {
            errors[v] := "Does not exist"
        }
    }
    newVerName := updCheck.name
    RunWait %comspec% /C "RD "%destDir%" & MKLINK /J "%destDir%" "%destDir%.%newVerName%"",, Min
    If (ErrorLevel)
        errors["MKLINK"] := ErrorLevel
    return errors.Count() ? errors : true
}

SplitFileNameInUpdCheck(updCheck) {
    local
    SplitPath % updCheck.url, dlName
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
