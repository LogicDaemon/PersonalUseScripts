;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

#include *i <find7zexe>
If (!exe7z)
    exe7z := "7z.exe"

mask := A_Is64bitOs ? "aria2-*-win-64bit-build*.zip" : "aria2-*-win-32bit-build*.zip"

latestPath := latestVer := latestbuild := ""
Loop Files, %mask%
{
    If (RegexMatch(A_LoopFileName, "^aria2-(?P<ver>\d+(?:\.\w+)*).*-build(?P<build>\d*)\.zip$", m)) {
        mver .= "." mbuild
        If (VerCompare(mver, latestVer) > 0) {
            latestVer := mver, latestPath := A_LoopFileFullPath
        }
    }
}

If (latestPath = "") {
    FileAppend Error: No suitable version of aria2 found in "%LOCALAPPDATA%\Temp"`n, **, CP1
    ExitApp 1
}

InstallDist(latestPath)
ExitApp

InstallDist(latestPath) {
    local
    global exe7z
    EnvGet LocalAppData,LOCALAPPDATA
    
    tempDir = %LocalAppData%\Programs\aria2.tmp
    destBase = %LocalAppData%\Programs
    destLink = %destBase%\aria2
    
    FileRemoveDir %tempDir%, 1
    removeTemp := true
    Try {
        FileAppend Running %exe7z%`n, **, CP1
        RunWait "%exe7z%" x -aoa -y -o"%tempDir%" -- "%latestPath%",, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Failed to extract the distributive to temp dir",, latestPath " to " tempDir)
        unpackedDirsCount := 0
        Loop Files, %tempDir%\*.*, D
        {
            If (StartsWith(A_LoopFileName, "aria2-")) {
                If (unpackedDirsCount > 0)
                    Throw Exception("Error: More than one unpacked directory found",, A_LoopFileLongPath)
                unpackedDirsCount++, unpackedDist := A_LoopFileFullPath, unpackedDirName := A_LoopFileName
            }
        }
        If (unpackedDirsCount == 0)
            Throw Exception("Error: No matching subdirs unarchived",, latestPath)
        destPerVer=%destBase%\%unpackedDirName%
        If (FileExist(destPerVer))
            Throw Exception("Error: The destination directory already exists",, destPerVer)
        Try {
            FileMoveDir %unpackedDist%, %destPerVer%, R
        } Catch e {
            Throw Exception("Error: Failed to move the unpacked directory to destination",, unpackedDist " to " destPerVer)
        }
        FileRemoveDir %tempDir%, 1
        removeTemp := ErrorLevel

        Try {
            FileRemoveDir %destLink%
            FileDelete %destLink%
        }
        If (FileExist(destLink))
            Throw Exception("Error: Failed to remove the old link",, destLink)
        RunWait %comspec% /C "MKLINK /D "%destLink%" "%destPerVer%" || MKLINK /J "%destLink%" "%destPerVer%"",, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Error: Failed to create a symlink to the unpacked directory",, destLink " to " destPerVer)
        return true
    } Catch e {
        errorText := ""
        For k, v in e
            errorText .= k ": " v "`n"
        FileAppend Exception %errorText%, **, CP1
        If (removeTemp)
            FileRemoveDir %tempDir%, 1
        return false
    }
}

#include <StartsWith>
