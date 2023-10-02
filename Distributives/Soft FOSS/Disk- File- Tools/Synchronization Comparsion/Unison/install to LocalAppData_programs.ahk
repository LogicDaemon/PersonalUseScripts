;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8
Global LocalAppData, exe7z, stderr

EnvGet LocalAppData,LOCALAPPDATA
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
silent := RunInteractiveInstalls=="0"

stderr := FileOpen("**", "w", "CP1")

#include *i <find7zexe>
If (!exe7z)
    exe7z := "7z.exe"

needSuffix := A_Is64bitOS ? "x86_64" : "i386"

FileRead latestAssetsRaw, %A_ScriptDir%\latest_assets.json
For i, asset in JSON.Load(latestAssetsRaw).assets {
    assetName := asset.name
    ;unison-2.53.3-windows-x86_64.zip
    ;unison-2.53.3-windows-i386.zip
    ;unison-v2.51.4_rc2+ocaml-4.12.0+x86_64.windows.zip
    ;unison-v2.51.4_rc2+ocaml-4.10.1+i386.windows.zip

    If (!(assetName ~= "(" needSuffix "\.windows|-windows-" needSuffix ")\.zip" )) {
        Continue
    }
    relPath := StrReplace(RegExReplace(asset.browser_download_url, "^\w+://", ""), "/", "\")
    SplitPath relPath,, subDir
    assetPath := A_ScriptDir "\" subDir "\" assetName

    If (!FileExist(assetPath))
        Continue
    
    Loop
    {
        Try {
            InstallDistToLocalAppData("unison", assetPath)
        } Catch e {
            errorText := ""
            For k, v in e
                errorText .= k ": " v "`n"
            FileAppend Exception %errorText%, **, CP1
            If (!silent) {
                MsgBox 0x12 , %A_ScriptName%, %errorText%
                IfMsgBox Retry
                    Continue
                IfMsgBox Ignore
                    Break
                ; IfMsgBox Abort
                ;     ExitApp
            }
        }
        ExitApp
    }
}
ExitApp 1

InstallDistToLocalAppData(name, distPath, subdirRegexInArchive := "", installDirOverride := "") {
    If (!IsSet(stderr))
        stderr := FileOpen("**", "w", "CP1")
    tempDir = %LocalAppData%\Programs\%name%.tmp
    destBase = %LocalAppData%\Programs
    destLink = %destBase%\%name%
    
    Try FileRemoveDir %tempDir%, 1
    removeTemp := true
    runcmd = "%exe7z%" x -aoa -y -o"%tempDir%" -- "%distPath%"
    
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
            SplitPath distPath,, unpackedDirName
            SplitPath distPath, , , , unpackedDirName
            unpackedDist := tempDir
        }
        destPerVer : = installDirOverride == "" ? destBase "\" unpackedDirName 
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

#include <JSON>
