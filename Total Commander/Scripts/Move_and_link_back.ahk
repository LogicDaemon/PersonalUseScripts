;Move_and_link_back.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;MsgBox % list of objects: %1%`ndestination where they will be linked: %2%

If (A_Args.Length() != 2) {
    MsgBox 0, %A_ScriptName%,
    (LTrim
    Usage:
    %A_ScriptName% <src-list> <dst-dir>
    src-list path to a file containing list of files or directories (dirs end with "\")
    dst-dir destination where they will be moved
    )
    ExitApp
}

pathSrcList := A_Args[1]
dstDir_BS := A_Args[2]
If (SubStr(dstDir_BS, 0) != "\") ; TC appends \ on its own
    dstDir_BS .= "\"
movePrefix := ".~" A_ScriptName "$"

If (!FileExist(pathSrcList)) {
    CheckError("Listfile """ pathSrcList """ does not exist!", -1)
} Else {
    If (dstExist := FileExist(dstDir_BS)) {
        If (!InStr(dstExist, "D"))
            CheckError("""" dstDir_BS """ already exists and not a directory", -1)
    } Else {
        FileCreateDir %dstDir_BS%
        If (ErrorLevel)
            CheckError("Creating """ dstDir_BS """", A_LastError)
    }
}

If (errors := CheckError()) {
    MsgBox 48, A_ScriptName, %errors%
    Exit 4
}

Menu Tray, Add, Show Hidden cmd, showcPID

                   ; [name, mklink option, use temporary location as link destination?]
                   ; non-admin               , admin
mklinkTypes := { 0: {0: ["Hardlink", "/H", -1], 1: ["File Symlink", "", 0]        }   ; File
               , 1: {0: ["Junction", "/J", 1], 1: ["Directory Symlink", "/D", 0] } } ; Directory

succeededAtLeastOne := 0
Loop Read, % pathSrcList
{
    SplitPath A_LoopReadLine, SrcName, SrcDir ;,,, SrcDrive
    srcPath := A_LoopReadLine
    isDir := SrcName==""
    mklinkType := mklinkTypes[isDir][A_IsAdmin]
    linkName := mklinkType[1], mklinkArg := mklinkType[2]
    
    If (mklinkType[3] >= 0) ; if mklinkType[3] == -1, then it's File hardlink, no reason to rename source file
        Menu Tray, Tip, Renaming %srcPath% before moving
    If (isDir) { ; Directory
        srcPath := SrcDir
        SplitPath SrcDir, SrcDirName, SrcDirDir ;,,, SrcDrive
        dst := dstDir_BS SrcDirName
        If (FileExist(dst)) {
            CheckError("""" dst """ already exists", -1)
            continue
        }
        srcDirTmp := SrcDirDir "\" movePrefix SrcDirName
        FileMoveDir %SrcDir%, %srcDirTmp%, R
    } Else { ; File
        If (mklinkType[3] >= 0) { ; if mklinkType[3] == -1, then it's File hardlink, no reason to rename source file
            srcTmp := SrcDir "\" movePrefix SrcName
            dst := dstDir_BS SrcName
            If (FileExist(dst)) {
                CheckError("""" dst """ already exists", -1)
                continue
            }
            FileMove %srcPath%, %srcTmp%
        } Else {
            dst := srcPath
            srcPath := dstDir_BS SrcName
        }
    }
    If (ErrorLevel)
        CheckError("Renaming """ srcPath """ to " movePrefix "*", A_LastError) && continue
    
    Menu Tray, Tip, Creating %linkName%
    SetTimer showcPID, -3000
    RunWait "%comspec%" /C "MKLINK %mklinkArg% "%srcPath%" "%dst%"",,Hide UseErrorLevel, cPID
    SetTimer showcPID, Off
    CheckError("creating " linkName """" dst """ for """ srcPath """") || succeededAtLeastOne := 1
    
    If (mklinkType[3] >= 0) { ; if mklinkType[3] == -1, then it's File hardlink, source has not been renamed
        If (isDir) {
            Menu Tray, Tip, Moving %srcDirTmp% to %dst%
            FileMoveDir %srcDirTmp%, %dst%
            If (ErrorLevel && CheckError("Moving """ srcDirTmp """ to """ dst """", A_LastError)) {
                MsgBox 0x30, %A_ScriptName%, % "Bad state: """ srcDirTmp """ is partially moved to """ dst """"
                ;FileMoveDir %SrcDir%%movePrefix%, %SrcDir%, R
                break
            }
        } Else { ; File
            Menu Tray, Tip, Moving %srcTmp% to %dst%
            FileMove %srcTmp%, %dst%
            If (ErrorLevel && CheckError("Moving """ srcTmp """ to """ dst """", A_LastError)) {
                FileMove %srcTmp%, %srcPath%
                If (!ErrorLevel)
                    FileDelete %dst%
                continue
            }
        }
    }
    Menu Tray, Tip
}

If (errors := CheckError()) {
    MsgBox 48, A_ScriptName, % (succeededAtLeastOne ? "Some files were linked" : "No files were linked") . ", errors:`n" . errors
    ExitApp 2-succeededAtLeastOne
}

showcPID() {
    global cPID
    GroupAdd cshow, ahk_pid %cPID%
    WinShow ahk_group cshow
}

CheckError(ByRef errorText := "", ByRef errLevel := "") {
    static errors := ""
    If (errorText) {
        If (errLevel=="")
            If (!(errLevel := ErrorLevel))
                return 0
        errors .= "[" errLevel "] " errorText "`n"
        FileAppend Error %errLevel% %errorText%`n,*,CP1
        return errLevel
    } Else {
        return errors
    }
}
