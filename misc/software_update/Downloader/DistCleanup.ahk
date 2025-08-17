; Cleans up directory skipping some files.
;
; "Cleanup" means either running %cleanup_action% with them
; or moving them to the "*_old" subdirectory by means of mvold.ahk.
;
; If only argument is given, it's the exception, and the mask is *.the_exception_extension.
; If two or more aruments, first is the mask, and others are exclusions.
;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#Warn
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (!A_Args[1]) {
    MsgBox 0, %A_ScriptName%, Usage: DistCleanup.ahk [mask] exclusion1 [exclusion2 ...]
    ExitApp 1
}

If (A_Args.MaxIndex() = 1) {
    exclusion := A_Args[1]
    SplitPath exclusion, exclusion, cleanupDir, extension
    CleanupDir(cleanupDir "\*." extension, [exclusion])
} Else {
    exclusions := A_Args.Clone()
    exclusions.Delete(0)
    mask := exclusions.RemoveAt(1)
    CleanupDir(mask, exclusions)
}

ExitApp

CleanupDir(mask, exclusions) {
    #Warn LocalSameAsGlobal, Off
    local
    SplitPath mask, maskFileName, maskDir
    If (!maskDir)
        maskDir := NormalizeDir(A_WorkingDir)

    ; sanitize exclusions
    exclusionsSet := {}
    For index, exclusion in exclusions {
        If (InStr(exclusion, "\")) {
            SplitPath exclusion, excFileName, excDir
            If (NormalizeDir(excDir) != maskDir)
                Continue
            exclusionsSet[Format("{:L}", excFileName)] := ""
            Continue
        }
        exclusionsSet[Format("{:L}", exclusion)] := ""
    }

    ; find non-excluded files matching the mask
    filesToRemove := []
    Loop Files, % mask
    {
        If (exclusionsSet.HasKey(Format("{:L}", A_LoopFileName)))
            Continue
        filesToRemove.Push(A_LoopFileName)
    }

    EnvGet cleanup_action, cleanup_action
    If (cleanup_action) {
        For index, file in filesToRemove
            RunWait %cleanup_action% "%maskDir%\%file%"
    } Else {
        For index, file in filesToRemove
            MoveToOld(maskDir "\" file)
    }
}

NormalizeDir(path) {
    If (!path)
        Return A_WorkingDir
    Loop Files, %path%, D
        Return A_LoopFileLongPath
}

#include %A_LineFile%\..\mvold.ahk
