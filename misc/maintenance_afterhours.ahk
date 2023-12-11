;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

;KillProcesses([ "conhost.exe"
;                 , "git.exe" ])

If (FileExist("w:\FileHistory\" A_UserName)) {
    Loop Files, w:\FileHistory\%A_UserName%\*.*, D
        CompactCompressible(A_LoopFileFullPath "\Data")
}

If (A_IsAdmin) {
    SetWorkingDir %A_ScriptDir%
    Run "%A_AhkPath%" "%A_ScriptDir%\vscode-update.ahk"
    Run "%A_AhkPath%" "%A_ScriptDir%\vscode-insiders-update.ahk"
    Run "%A_AhkPath%" "%A_ScriptDir%\update_go.ahk"
    Run "%A_AhkPath%" "%A_ScriptDir%\update_KeePass.ahk"
    
    Run %comspec% /C "%A_ScriptDir%\Update_SysInternals.cmd",, Min
    
    RunWait %comspec% /C "%A_ScriptDir%\update-git-for-windows.cmd",, Min
    RunWait %comspec% /C "%A_ScriptDir%\update_aws_cli.cmd",, Min
    RunWait %comspec% /C "%A_ScriptDir%\update_obs.cmd",, Min
    RunWait "%LOCALAPPDATA%\Programs\msys64\ucrt64.exe" pacman -Suy --noconfirm,, Min
    RunWait "%LOCALAPPDATA%\Programs\msys64\ucrt64.exe" paccache -r --noconfirm,, Min
}
RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
backupScript=%A_ScriptDir%\backup_%hostname%.cmd
If (FileExist(backupScript))
    Run %comspec% /C "%A_ScriptDir%\backup_%hostname%.cmd",, Min

ExitApp

KillProcesses(processesNames) {
    For i, procName in killProcesses {
        WinKill ahk_exe %procName%,,5
        While true {
            Process Exist, %procName%
            If (!ErrorLevel)
                break
            If (prevPID == ErrorLevel) {
                RunWait taskkill.exe /IM %procName% /F,, Min UseErrorLevel
                break
            } Else {
                prevPID := ErrorLevel
                Process Close, %procName%
            }
        }
    }
}

CompactCompressible(dir) {
    definitelyCompress :=   { "js": ""
                            , "json": ""
                            , "md": ""
                            , "ts": ""
                            , "txt": ""
                            , "xml": ""
                            , "yml": ""
                            , "pyi": ""
                            , "yaml": "" }
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
    Loop Files, %dir%\*.*, FD
    {
        If (InStr(A_LoopFileAttrib, "D")) {
            CompactCompressible(A_LoopFileFullPath)
            Continue
        }
        If (definitelyIgnore.HasKey(A_LoopFileExt))
            Continue
        If (definitelyCompress.HasKey(A_LoopFileExt)) {
            compress := definitelyCompress[A_LoopFileExt]
        }
        ; ToDo: collect statistics for remaining files
        If (!compress)
            compress := "/EXE:LZX"
        RunWait compact.exe /C /EXE:LZX "%A_LoopFileFullPath%",, Hide UseErrorLevel
    }
}
