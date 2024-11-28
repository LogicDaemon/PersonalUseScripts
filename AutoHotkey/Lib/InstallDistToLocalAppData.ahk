;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

InstallDistToLocalAppData(name, distPath, subdirRegexInArchive := "", installDirOverride := "", args7z := "") {
    ; name is the name of the distribution, e.g. "qBittorrent".
    ;   That is how a symlink or junction in %LocalAppData%\Programs will be named.
    ; distPath is path to the archive to unpack. Must be a specific file name, not a mask.
    ;   That name should be unique (include version number, etc.), because the archive will be unpacked
    ;   to a directory with the same name.
    ; subdirRegexInArchive is a regex to match a subdirectory in the archive.
    ; installDirOverride is a path to the directory to unpack the distribution to,
    ;   instead of %LocalAppData%\Programs\%name of distPath%.
    ; args7z are additional arguments to pass to 7z.exe.
    ; For example:
    ; InstallDistToLocalAppData("qBittorrent", A_ScriptDir "\qbittorrent_4.6.3_x64_setup.exe")
    local
    global exe7z
    If (!exe7z)
        GoSub ImportFind7zExe
    If (!LocalAppData)
        EnvGet LocalAppData, LOCALAPPDATA
    If (!IsSet(stderr))
        stderr := FileOpen("**", "w", "CP1")
    tempDir = %LocalAppData%\Programs\%name%.tmp
    destBase = %LocalAppData%\Programs
    destLink = %destBase%\%name%
    
    Try FileRemoveDir %tempDir%, 1
    removeTemp := true
    runcmd = "%exe7z%" x -aoa -y -o"%tempDir%" %args7z% -- "%distPath%"
    
    stderr.WriteLine("> " runcmd)
    Try {
        RunWait %runcmd%,, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Failed to extract the distributive to temp dir",, distPath " to " tempDir)
        If (subdirRegexInArchive) {
            unpackedDirsCount := 0
            Loop Files, %tempDir%\*.*, D
            {
                If (A_LoopFileName ~= subdirRegexInArchive) {
                    If (unpackedDirsCount > 0)
                        Throw Exception("Error: More than one matching unpacked directory found",, A_LoopFileLongPath)
                    unpackedDirsCount++, unpackedDist := A_LoopFileFullPath, unpackedDirName := A_LoopFileName
                }
            }
            If (unpackedDirsCount == 0)
                Throw Exception("Error: No matching subdirs unarchived",, distPath)
        } Else {
            SplitPath distPath, , , , unpackedDirName
            unpackedDist := tempDir
        }
        destPerVer := installDirOverride == "" ? (destBase "\" unpackedDirName)
            : ( installDirOverride ~= "^\w:\\|^\\\\" ? installDirOverride
            : destBase "\" installDirOverride)
        If (FileExist(destPerVer))
            Throw Exception("Error: The destination directory already exists",, destPerVer)
        SplitPath destPerVer, , destBaseDir
        Try FileCreateDir %destBaseDir%
        Try {
            FileMoveDir %unpackedDist%, %destPerVer%, R
        } Catch e {
            Throw Exception("Error: Failed to move the unpacked directory to destination",, unpackedDist " to " destPerVer)
        }
        Try FileRemoveDir %tempDir%, 1
        removeTemp := ErrorLevel
        
        Try FileRemoveDir %destLink%
        If (FileExist(destLink))
            Throw Exception("Error: Failed to remove the old link/junction",, destLink)
        RunWait %comspec% /C "MKLINK /J "%destLink%" "%destPerVer%"",, Min UseErrorLevel
        If (ErrorLevel)
            Throw Exception("Error: Failed to create a junction for the unpacked directory",, destLink " to " destPerVer)
    } Catch e {
        If (removeTemp)
            Try FileRemoveDir %tempDir%, 1
        Throw e
    }
}

ImportFind7zExe:
    #include *i <find7zexe>
    If (!exe7z)
        exe7z := "7z.exe"
Return
