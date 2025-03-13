;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance ignore
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

compressCmdPrefix := "compact.exe /C /EXE:LZX"
defaultCompactArg := "/EXE:LZX"
compactMinSize := 131072
definitelyCompress :=   { "js": defaultCompactArg
                        , "json": defaultCompactArg
                        , "md": defaultCompactArg
                        , "ts": defaultCompactArg
                        , "txt": defaultCompactArg
                        , "xml": defaultCompactArg
                        , "yml": defaultCompactArg
                        , "pyi": defaultCompactArg
                        , "yaml": defaultCompactArg }
definitelyIgnore := { "7z": ""
                    , "aac": ""
                    , "ape": ""
                    , "avi": ""
                    , "bz2": ""
                    , "cab": ""
                    , "flac": ""
                    , "flv": ""
                    , "gif": ""
                    , "gz": ""
                    , "jpeg": ""
                    , "jpg": ""
                    , "m4a": ""
                    , "m4v": ""
                    , "mkv": ""
                    , "mov": ""
                    , "mp3": ""
                    , "mp4": ""
                    , "ogg": ""
                    , "png": ""
                    , "rar": ""
                    , "webm": ""
                    , "wma": ""
                    , "wmv": ""
                    , "xz": ""
                    , "zip": "" }
                    
; --- Cleanup ---
; Remove Microsoft Edge auto-launch
Run "%A_AhkPath%" "%A_ScriptDir%\RemoveMicrosoftEdgeAutoLaunch.ahk"

; Check if VS Code is running
For i, procName in ["Code.exe", "Code - Insiders.exe", "code-insiders.exe"] {
    Process Exist, %procName%
    If (ErrorLevel) {
        foundVSCode := ErrorLevel
        break
    }
}
If (!foundVSCode) {; VS Code is not running
    KillProcesses([ "git.exe" ]) ; Kill git.exe to avoid update issues
}

; Hard link duplicates between VS Code and VS Code Insiders extensions and compact them
RunWait "%LocalAppData%\Programs\DFHL_2.6\DFHL.exe" /r /l /o .vscode .vscode-insiders, %USERPROFILE%, Hide
For _, comprDir in [ USERPROFILE "\.vscode"
                , USERPROFILE "\.vscode-insiders\" ] {
    If (FileExist(comprDir)) {
        CompactCompressible(A_LoopFileFullPath "\Data")
    }
}

SetWorkingDir %A_ScriptDir%

; --- Update ---
; Start updates without administrator privileges
For script in [ "vscode-update.ahk"
              , "vscode-insiders-update.ahk"
              , "update_go.ahk"
              , "update_KeePass.ahk"
              , "scoop_update_apps.ahk" ] {
    RunWait "%A_AhkPath%" "%A_ScriptDir%\nprivRun.ahk" "%A_ScriptDir%\%script%"
}

; These also do not require admin privileges, but their window will appear
; and steal focus if started through nprivRun.ahk
Run %comspec% /C "%A_ScriptDir%\Update_SysInternals.cmd",, Hide
RunWait %comspec% /C "%A_ScriptDir%\update-git-for-windows.cmd",, Hide
RunWait %comspec% /C "%A_ScriptDir%\update_aws_cli.cmd",, Hide
RunWait %comspec% /C "%A_ScriptDir%\update_obs.cmd",, Hide

If (FileExist("%LOCALAPPDATA%\Programs\msys64\ucrt64.exe")) {
    RunWait "%LOCALAPPDATA%\Programs\msys64\ucrt64.exe" pacman -Suy --noconfirm,, Hide
    RunWait "%LOCALAPPDATA%\Programs\msys64\ucrt64.exe" paccache -r --noconfirm,, Hide
}

; --- Backup ---
; Start the host-specific backup script
RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
backupScript=%A_ScriptDir%\backup_%hostname%.cmd
If (FileExist(backupScript))
    Run %comspec% /C "%A_ScriptDir%\backup_%hostname%.cmd",, Hide

; If the file history is local, compact files in it
comprDir := "w:\FileHistory\" A_UserName
If (FileExist(comprDir)) {
    Loop Files, %comprDir%\*.*, D
        CompactCompressible(A_LoopFileFullPath "\Data")
}

ExitApp

KillProcesses(processesNames) {
    For i, procName in killProcesses {
        WinKill ahk_exe %procName%,,5
        While true {
            Process Exist, %procName%
            If (!ErrorLevel)
                break
            If (prevPID == ErrorLevel) {
                RunWait taskkill.exe /IM "%procName%" /F,, Hide UseErrorLevel
                break
            } Else {
                prevPID := ErrorLevel
                Process Close, %procName%
            }
        }
    }
}

CompactCompressible(dir) {
    global compactMinSize, defaultCompactArg, definitelyCompress, definitelyIgnore, compressCmdPrefix
    compressPaths := []
    compress := compressPID := ""
    Loop Files, %dir%\*.*, FD
    {
        If (InStr(A_LoopFileAttrib, "D")) {
            CompactCompressible(A_LoopFileFullPath)
            Continue
        }
        If (A_LoopFileSize < compactMinSize || definitelyIgnore.HasKey(A_LoopFileExt))
            Continue
        If (definitelyCompress.HasKey(A_LoopFileExt)) {
            compress := definitelyCompress[A_LoopFileExt]
        }
        ; ToDo: collect statistics for remaining files
        If (!compress)
            compress := defaultCompactArg
        compressPaths.Push(A_LoopFileName)
    }
    maxCmdLength := 8191 - StrLen(compressCmdPrefix) - 1
    compressPathsStr := ""
    For _, path in compressPaths {
        If (StrLen(compressPathsStr)+StrLen(path)+3 >= maxCmdLength) { ; 3 for space and "" around the path
            compressPID := WaitProcessClose(compressPID)
            Run %compressCmdPrefix%%compressPathsStr%, %dir%, Hide UseErrorLevel, compressPID
        }
        compressPathsStr .= " """ path """"
    }
    If (compressPathsStr) {
        WaitProcessClose(compressPID)
        RunWait %compressCmdPrefix%%compressPathsStr%, %dir%, Hide UseErrorLevel
    }
}

WaitProcessClose(pPID) {
    If (!pPID)
        Return
    Loop
    {
        Process Exist, %pPID%
        If (!ErrorLevel)
            Return
        Sleep 1000
    }
}
