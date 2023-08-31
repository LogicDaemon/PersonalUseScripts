CopyMirror(srcMask, destDir, doOverwrite := false) {
    local
    ; Copy srcMask to destDir and remove anything that matches srcMask in destDir but not exist in srcMask.
    ; Returns the number of errors.
    
    ; First copy all the files (but not the folders):
    FileCopy %srcMask%, %destDir%, %doOverwrite%
    errorCount := ErrorLevel
    ; Now copy all the folders:
    Loop Files, %srcMask%, D
    {
        FileCopyDir, %A_LoopFileFullPath%, %destDir%\%A_LoopFileName%, %doOverwrite%
        ErrorCount += ErrorLevel
    }
    
    RemoveExtra(srcMask, destDir)
    
    return ErrorCount
}

RemoveExtraFiles(srcMask, destDir) {
    local
    ; Removes from destDir files which match the srcMask mask but do not exist in the directory specified by srcMask.
    SplitPath srcMask, srcFileMask, srcDir
    
    filesToDel := []
    dirsToDel := []
    Loop Files, %destDir%\%srcMask%, FD
    {
        nameIsDir := InStr(A_LoopFileAttrib, "D")
        If (!FileExist(srcDir "\" A_LoopFileName)) {
            If (nameIsDir)
                dirsToDel.Push(A_LoopFileName)
            Else
                filesToDel.Push(A_LoopFileName)
        } Else If (nameIsDir) {
            RemoveExtra(srcDir "\" A_LoopFileName "\" srcFileMask, A_LoopFileFullPath)
        }
    }
    
    For _, fName in filesToDel {
        MsgBox Delete %destDir%\%fName%
        FileDelete %destDir%\%fName%
        errors += !!ErrorLevel
    }
    For _, dirName in dirsToDel {
        MsgBox Remove directory %destDir%\%dirName%
        FileRemoveDir %destDir%\%dirName%, 1
        errors += !!ErrorLevel
    }
    return errors
}
