;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
#Warn
FileEncoding UTF-8
EnvGet LocalAppData,LOCALAPPDATA

#include *i <find7zexe>
If (!exe7z)
    exe7z := "7z.exe"

distName = aria2
destBase = %LocalAppData%\Programs
mask := distName . (A_Is64bitOs ? "-*-win-64bit-build*.zip" : "-*-win-32bit-build*.zip")

latestPath := latestVer := latestbuild := ""
Loop Files, %mask%
{
    If (RegexMatch(A_LoopFileName, "^" distName "-(?P<ver>\d+(?:\.\w+)*).*-build(?P<build>\d*)\.zip$", m)) {
        mver .= "." mbuild
        If (VerCompare(mver, latestVer) > 0) {
            latestVer := mver, latestPath := A_LoopFileFullPath
        }
    }
}

If (!latestPath) {
    FileAppend Error: No suitable version found`n, **, CP1
    ExitApp 1
}

installedDirs := InstallDist(latestPath, distName)
If (!installedDirs)
    ExitApp 1

skipDirs := {}
For _, dir in installedDirs {
    Loop Files, %dir%, D
    {
        skipDirs[A_LoopFileLongPath] := ""
        Break
    }
}

Loop Files, %destBase%\%distName%-*, D
{
    If (skipDirs.HasKey(A_LoopFileLongPath))
        Continue
    Try {
        FileRemoveDir %A_LoopFileFullPath%, 1
    } Catch {
        FileAppend Error: Failed to remove the old version %A_LoopFileName%`n, **, CP1
    }
}
ExitApp

InstallDist(ByRef archivePath, ByRef distName, archiveWithSubdir:=True) {
    ; Unpack archivePath archive to destPerVer = %LocalAppData%\Programs\%distName%
    ; and link to destLink = %destBase%\%distName%
    ; If archiveWithSubdir is True (default), the archive should only contain single subdirectory
    ;   which is moved to destPerVer; otherwise, destPerVer will contail the full archive contents.
    ; Returns [destLink, destPerVer] on success, or "" on any error.
    Global exe7z, destBase, LocalAppData
    
    tempDir = %destBase%\%distName%.tmp
    destLink = %destBase%\%distName%
    
    FileRemoveDir %tempDir%, 1
    If (!archiveWithSubdir) {
        unpackedDist := tempDir
        SplitPath archivePath,,,, unpackedDirName
        If (FileExist(destBase "\" unpackedDirName))
            Throw Exception("Error: The destination directory already exists",, destBase "\" unpackedDirName)
    }
    removeTemp := True
    FileAppend Running %exe7z%`n, **, CP1
    ; FileAppend inside try fails if the stderr is not redirected to a file
    Try {
        RunWait "%exe7z%" x -aoa -y -o"%tempDir%" -- "%archivePath%",, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Failed to extract the distributive to temp dir",, archivePath " to " tempDir)
        If (archiveWithSubdir) {
            unpackedDirsCount := 0
            Loop Files, %tempDir%\*.*, D
            {
                If (StartsWith(A_LoopFileName, distName "-")) {
                    If (unpackedDirsCount > 0)
                        Throw Exception("Error: More than one unpacked directory found",, A_LoopFileLongPath)
                    unpackedDirsCount++, unpackedDist := A_LoopFileFullPath, unpackedDirName := A_LoopFileName
                }
            }
            If (unpackedDirsCount == 0)
                Throw Exception("Error: No matching subdirs unarchived",, archivePath)
        }
        destPerVer = %destBase%\%unpackedDirName%
        If (FileExist(destPerVer))
            Throw Exception("Error: The destination directory already exists",, destPerVer)
        Try {
            FileMoveDir %unpackedDist%, %destPerVer%, R
        } Catch e {
            Throw Exception("Error: Failed to move the unpacked directory to destination",, unpackedDist " to " destPerVer)
        }
        If (FileExist(tempDir)) {
            Try FileRemoveDir %tempDir%, 1
            removeTemp := ErrorLevel
        } Else {
            removeTemp := False
        }
        Try FileRemoveDir %destLink%
        Try FileDelete %destLink%
        If (FileExist(destLink))
            Throw Exception("Error: Failed to remove the old link",, destLink)
        RunWait %comspec% /C "MKLINK /D "%destLink%" "%destPerVer%" || MKLINK /J "%destLink%" "%destPerVer%"",, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Error: Failed to create a symlink to the unpacked directory",, destLink " to " destPerVer)
        Return [destLink, destPerVer]
    } Catch e {
        errorText := ""
        For k, v in e
            errorText .= k ": " v "`n"
        FileAppend Exception %errorText%, **, CP1
        If (removeTemp)
            FileRemoveDir %tempDir%, 1
        Return
    }
}

#include <StartsWith>
