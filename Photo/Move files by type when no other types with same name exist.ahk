#NoEnv

movesubDir := "\_removed"
, allDirs := []                 ; allDirs[dirIdx] := dirName
, dirsIdxes := {}               ; dirsIdxes[dirName] := dirIdx
, allFiles := {}                ; allFiles[namenoext][dirIdx][ext] := ""
, dirsWithNonUniqueFiles := []  ; dirsWithNonUniqueFiles[dirIdx] := ""

flog := FileOpen(A_Temp "\" A_ScriptName ".log", "a")
flog.WriteLine(A_Now A_Tab "Starting")

If (A_Args.Length()) {
    For i,arg in A_Args
        flog.WriteLine(A_Now A_Tab "Scanning " arg), CheckDirForExts(arg)
} Else {
    DriveGet disks, List, REMOVABLE
    Loop Parse, disks
        flog.WriteLine(A_Now A_Tab "Scanning " A_LoopField), CheckDirForExts(A_LoopField ":\DCIM\*.*") 
}
flog.WriteLine(A_Now A_Tab "Scanned: " ObjectToText(allDirs) A_Tab "Found: " ObjectToText(allFiles)
              . "`n" A_Tab A_Tab A_Tab "Looking for dirs with unique-only files")

For name, fileExtsInDirs in allFiles {
    If (fileExtsInDirs.Count() > 1) {
        ; if name is in more than 1 dir, remove that dir from uniqueOnlyFilesDirs
        For dirIdx in fileExtsInDirs
            dirsWithNonUniqueFiles[dirIdx] := ""
        ; also remove that file from lists, since it has duplicates with other exts
        allFiles[name] := "" ; non-unique
        ; ToDo: check for same extension in different dirs, in which case compare files and if they're different, treat them as such
    }
}

For name, fileExtsInDirs in allFiles {
    If (IsObject(fileExtsInDirs)) { ; all unique files are removed in the loop above
        For dirIdx, extsInDir in fileExtsInDirs {
            If (dirsWithNonUniqueFiles.HasKey(dirIdx))  { ; any dirs which aren't in dirsWithNonUniqueFiles don't have any duplicate files, no need to scan them.
                ;MsgBox % "Creating dir " allDirs[dirIdx] movesubDir
                FileCreateDir % allDirs[dirIdx] movesubDir
                For ext in extsInDir {
                    namewithext := name . ("" ? ext == "" : "." ext)
                    flog.WriteLine(A_Now A_Tab allDirs[dirIdx] "\" namewithext " → …" movesubDir "\")
                    ;MsgBox % allDirs[dirIdx] "\" namewithext " → …" movesubDir "\"
                    FileMove % allDirs[dirIdx] "\" namewithext, % allDirs[dirIdx] movesubDir "\*.*"
                    If (ErrorLevel)
                        flog.WriteLine(A_Tab A_Tab A_Tab "!!! error " ErrorLevel " (System error: " A_LastError ")")
                }
            }
        }
    }
}

flog.WriteLine(A_Now A_Tab "Done.`n")
flog.Close()
Run %A_Temp%\%A_ScriptName%.log
ExitApp

CheckDirForExts(dir) {
    local
    global movesubDir, allFiles, allDirs, dirsIdxes
;    , allFilesByExt := {}           ; allFilesByExt[ext][namenoext][dirIdx] := ""
;    , allFiles := {}                ; allFiles[namenoext][dirIdx][ext] := ""
    If (!dir)
        Throw Exception("dir argument is empty")
    If (SubStr(dir, 0) == "\")
        dir := SubStr(dir, 1, -1) ; cut "\" from the end
    If (EndsWith(dir, movesubDir))
        return false
    Loop Files, %dir%\*.*, R
    {
        If (A_LoopFileDir != lastDir) {
            lastDir := A_LoopFileDir
            If (!dirIdx := dirsIdxes[A_LoopFileDir]) {
                dirIdx := allDirs.Push(A_LoopFileDir)
                dirsIdxes[A_LoopFileDir] := dirIdx
            }
        }
        
        extLen := StrLen(A_LoopFileExt)
        nameUpperNoExt := Format("{:Us}" , extLen ? SubStr(A_LoopFileName, 1, -extLen-1) : A_LoopFileName)
        
        If (nameUpperNoExt != prevNameUpperNoExt) {
            prevNameUpperNoExt := nameUpperNoExt
            If (!allFiles.HasKey(nameUpperNoExt)) { ; file appeared for the first time
                allFiles[nameUpperNoExt] := {(dirIdx): {(A_LoopFileExt): ""}}
                continue
            }
        }
        
        If (!allFiles[nameUpperNoExt].HasKey(dirIdx)) {
            allFiles[nameUpperNoExt][dirIdx] := {(A_LoopFileExt): ""} ; known file in a new directory
        } Else {
            allFiles[nameUpperNoExt][dirIdx][A_LoopFileExt] := "" ; known file with a new extension in same directory
        }
    }
}

#include <EndsWith>
