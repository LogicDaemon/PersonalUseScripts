;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; from https://stackoverflow.com/a/57601121:
; 1. find commit
; 2. download from https://update.code.visualstudio.com/commit:%commit%/server-linux-x64/stable
; 3. extract to %LocalAppData%\Programs\Microsoft VS Code\resources\app\server

If (A_Args.Length()) {
    If FileExist(A_Args[1])
        vscodeDistPath := A_Args[1]
    Else
        commit := A_Args[1]
} Else {
    vscodeDistPath := FindLatest("VSCode-win32-x64-*.*")
    If (!vscodeDistPath)
        Throw Exception("VSCode-win32-x64-* not found in %A_ScriptDir%",, A_ScriptDir)
}

#include <find7zexe>

If (!commit)
    commit := ReadVSCodeCommitFromDist(vscodeDistPath)

dlDestDir := A_ScriptDir "\server"
dlDestPath := dlDestDir "\vscode-server-linux-x64." commit ".tar.gz"
If (!InStr(FileExist(dlDestDir), "D"))
    FileCreateDir %dlDestDir%
Else If (FileExist(dlDestPath))
    ExitApp
RunWait curl.exe -L -o "%dlDestPath%.tmp" "https://update.code.visualstudio.com/commit:%commit%/server-linux-x64/insider", %dlDestDir%, Min UseErrorLevel
If (ErrorLevel)
    Throw Exception("curl error",, ErrorLevel)
FileMove %dlDestPath%.tmp, %dlDestPath%, 1

ReadVSCodeCommitFromDist(vscodeDistPath) {
    global exe7z

    SplitPath vscodeDistPath,,,, distName
    tempDir := A_Temp "\" A_ScriptName "_" distName "." A_TickCount ".tmp"
    RunWait "%exe7z%" x -o"%tempDir%" -- "%vscodeDistPath%" resources\app\product.json,, Min
    If (ErrorLevel)
        Throw ("7-Zip error",, ErrorLevel)
    
    json_path := tempDir "\resources\app\product.json"
    FileRead json_data, %json_path%
    If (ErrorLevel || !json_data)
        Throw Exception("Failed to read product.json",, json_path)
    
    product_data := JSON.Load(json_data)
    FileRemoveDir %tempDir%, 1
    
    return product_data["commit"]
}

FindLatest(mask) {
    Loop Files, %mask%
    {
        If A_LoopFileExt not in zip,7z
            Continue
        If (A_LoopFileTimeModified > lastTime) {
            lastTime := A_LoopFileTimeModified
            vscodeDistPath := A_LoopFileFullPath
        }
    }
    return vscodeDistPath
}

#include <JSON>
