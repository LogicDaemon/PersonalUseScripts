;Symlink.ahk
; %1% path to a file containing list of objects (files or directories)
; %2% destination where they will be linked

;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv

;MsgBox % list of objects: %1%`ndestination where they will be linked: %2%

If (!A_IsAdmin) {
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    RunWait *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    If (ErrorLevel = "ERROR")
        MsgBox 0x30, %A_ScriptName%, Elevated privilegies are required
    ExitApp
}
               ; non-admin,                 admin
mklinkTypes := { 0: {0: {"Hardlink": "/H"}, 1: {"File Symlink": ""}        } ; File
               , 1: {0: {"Junction": "/J"}, 1: {"Directory Symlink": "/D"} } } ; Directory

If (A_Args.Length() && FileExist(A_Args[1])) {
    Loop Read, % A_Args[1]
    {
        SplitPath A_LoopReadLine, SrcName, SrcDir ;,,, SrcDrive
        srcIsDir := SrcName==""
        mklinkType := mklinkTypes[srcIsDir][A_IsAdmin]
        srcPath := srcIsDir ? SrcDir : A_LoopReadLine
        If (srcIsDir)
            SplitPath SrcDir, SrcName, SrcDir
        For linkType, mklinkArg in mklinkType {
            SetTimer showcPID, -3000
            RunWait "%comspec%" /C "MKLINK %mklinkArg% "%2%%SrcName%" "%srcPath%"",,Hide UseErrorLevel, cPID
            SetTimer showcPID, Off
            If (ErrorLevel) {
                errorText = Error %ERRORLEVEL% creating %linkType% for %A_LoopReadLine%`n
                Errors .= errorText
                FileAppend %errorText%,*,CP1
            } Else {
                AtLeastOneSucceeded := 1
                break
            }
        }
    }
} Else {
    Errors=Listfile "%1%" does not exist!
    exitError := 4
}

If (Errors || exitError) {
    MsgBox 0x30, %A_ScriptName%, Errors occured while linking: %Errors%`nExitError: %exitError%
    Exit exitError ? exitError : 2-AtLeastOneSucceeded
}

showcPID() {
    global cPID
    GroupAdd cshow, ahk_pid %cPID%
    WinShow ahk_group cshow
}
