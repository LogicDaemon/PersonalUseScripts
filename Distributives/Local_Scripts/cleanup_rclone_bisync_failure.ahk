#NoEnv

ProcessDir("..")

ProcessDir(dir) {
    local
    files := {}
    oldWD := A_WorkingDir
    SetWorkingDir %dir%
    cur_dir := ""
    Loop Files, *.*, R
    {
        If (cur_dir != A_LoopFileDir) {
            CleanupRcloneFailedSyncDir(cur_dir, files)

            files := {}
            cur_dir := A_LoopFileDir
        }
        
        If ((p1 := EndsWith(A_LoopFileName, "..path1")) || EndsWith(A_LoopFileName, "..path2")) {
            nameWoSuff := SubStr(A_LoopFileName, 1, -7)
            If (!files.HasKey(nameWoSuff))
                files[nameWoSuff] := []
            files[nameWoSuff][2 - p1] := [A_LoopFileSize, A_LoopFileTimeModified]
        }
    }
    ; process files from the last dir
    CleanupRcloneFailedSyncDir(cur_dir, files)
    SetWorkingDir %oldWD%
}

CleanupRcloneFailedSyncDir(dir, files) {
    local
    If (!files.Count())
        return

    ;MsgBox % dir "`n" ObjectToText(files)

    For name, props in files {
        if (props.Count() < 2) {
            ;MsgBox % "Only single ""..pathX""-file found: " name
            continue
        }
        ;MsgBox % (props[1][1] == props[2][1]) "`n" props[1][1] "`n" props[2][1] "`n" name
        if (props[1][1] == props[2][1]) {
            ; sizes are identical
            ;MsgBox Sizes for %dir%\%name% are identical

            If (FilesIdentical(dir "\" name "..path1", dir "\" name "..path2")) {
                ; Files are identical, deleting the newer one
                olderFileIdx := (props[1][2] > props[2][2]) + 1
                newerFileIdx := 3 - olderFileIdx
                ;MsgBox Gonna delete`n%dir%\%name%..path%newerFileIdx%
                FileDelete %dir%\%name%..path%newerFileIdx%
                FileMove %dir%\%name%..path%olderFileIdx%, %dir%\%name%
            } Else {
                MsgBox % "Files different: " dir "\" name "..path1" " and " dir "\" name "..path2"
            }
        }
    }
}

FilesIdentical(path1, path2) {
    local

    blockSize := 1048576

    f1 := FileOpen(path1, "r", "cp0")
    If (!IsObject(f1))
        Throw Exception("Cannot open file",, path1)
    f2 := FileOpen(path2, "r", "cp0")
    If (!IsObject(f2)) {
        f1.Close()
        Throw Exception("Cannot open file",, path2)
    }
    VarSetCapacity(bFile1, blockSize)
    VarSetCapacity(bFile2, blockSize)
    Loop
    {
        sFile1 := f1.RawRead(bFile1, blockSize)
        sFile2 := f2.RawRead(bFile2, blockSize)
        If (sFile1 != sFile2)
            return False
        If (sFile1 == 0)
            return True
        If (sFile1 != DllCall("ntdll\RtlCompareMemory", "ptr", &bFile1, "ptr", &bFile2, "ptr", sFile1))
            return False
    }
    MsgBox Files seem to be identical: %path1% and %path2%
}
