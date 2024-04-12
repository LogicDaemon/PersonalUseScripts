;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
Global removeDirsBeforeExit := []

Try {
    exe7z := find7zexe()
} Catch {
    Try
        exe7z := find7zaexe()
    Catch
        exe7z := Get7zaFromExtra()
}

installBaseDir := LocalAppData "\Programs"
installLink := installBaseDir "\7-Zip"
distFor64BitOSRegexp := {0: "", 1: "-x64\.exe$"}
main7zDist := FindLatestByFileVersion( A_ScriptDir "\7-zip.org\a\7z*-x64.exe"
                                     , distFor64BitOSRegexp[A_Is64bitOS]
                                     , distFor64BitOSRegexp[!A_Is64bitOS] )

If (!main7zDist) {
    Throw Exception("7-Zip distribution not found")
    ExitApp 1
}

SplitPath main7zDist, , , , main7zDistName
installDest := installBaseDir "\" main7zDistName
RunWait %exe7z% x -aoa -y -o"%installDest%" -- "%main7zDist%", %A_Temp%, Min
If (FileExist(installLink))
    FileRemoveDir %installLink%
RunWait %comspec% /c MKLINK /J "%installLink%" "%installDest%", %A_Temp%, Min

; Update "HKEY_CURRENT_USER\Software\7-Zip" "Path"
RegWrite REG_SZ, HKEY_CURRENT_USER\Software\7-Zip, Path, %installLink%

For _, dir in removeDirsBeforeExit
    FileRemoveDir %dir%, 1

Exit

Get7zaFromExtra() {
    If (!FileExist(A_ScriptDir "\7-zip.org\a\7zr.exe"))
        Throw Exception("Need an installed 7-Zip or at least 7-zip.org\a\7zr.exe")
    SplitPath A_ScriptDir, ScriptDirName
    tempDir = %A_Temp%\%ScriptDirName%_%A_ScriptName%
    removeDirsBeforeExit.Push(tempDir)
    extrasArchive := FindLatestByNameVersion(A_ScriptDir "\7-zip.org\a\7z*-extra.7z")
    inArchivePath := A_Is64bitOS ? "x64\7za.exe" : "7za.exe"
    RunWait %A_ScriptDir%\7-zip.org\a\7zr.exe x -aoa -y -o"%tempDir%\" -- "%extrasArchive%" "%inArchivePath%"
    Return tempDir "\" inArchivePath
}

FindLatestByNameVersion(mask) {
    ; mask should be a path with * in place of version number
    starPos := InStr(mask, "*")
    If (starPos = 0)
        Throw Exception("Mask should contain *")
    preMask := SubStr(mask, 1, starPos-1)
    postMask := SubStr(mask, starPos+1)
    ; mask should be a path with * in place of version number
    Loop Files, %mask%
    {
        currentVersion := SubStr(A_LoopFileName, starPos, StrLen(A_LoopFileName)-StrLen(mask)+1)
        If (!latest || currentVersion > latestVersion) {
            latest := A_LoopFileFullPath
            latestVersion := currentVersion
        }
    }
    Return latest
}

FindLatestByFileVersion(mask, includeRegexp, excludeRegexp) {
    Loop Files, %mask%
    {
        If (includeRegexp && !(A_LoopFileName ~= includeRegexp))
            Continue
        If (excludeRegexp && A_LoopFileName ~= excludeRegexp)
            Continue
        FileGetVersion version, %A_LoopFileFullPath%
        If (!version)
            Continue
        If (!latest || version > latestVersion) {
            latest := A_LoopFileFullPath
            latestVersion := version
        }
    }
    Return latest
}

find7zexe(exename:="7z.exe", paths*) {
    local ; regPaths, bakRegView, i, regpath, currpath, ProgramFilesx86, SystemDrive, path, fullpath
    ;key, value, flag "this is path to exe (only use directory)"
    static regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,true]
                       ,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
                       ,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,true]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", true] ]
    
    bakRegView := A_RegView
    SetRegView 64
    For i,regpath in regPaths {
        Try {
            RegRead currpath, % regpath[1], % regpath[2]
            If (currpath) {
                If (regpath[3]) 
                    SplitPath currpath,,currpath
                SetRegView %bakRegView%
                return Check7zDir(Trim(currpath,""""), exename)
            }
        }
    }
    SetRegView %bakRegView%
    
    If (IsFunc("findexe")) {
        EnvGet ProgramFilesx86,ProgramFiles(x86)
        EnvGet SystemDrive,SystemDrive
        Try return Func("findexe").Call(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
        Try return Func("findexe").Call("7za.exe", SystemDrive . "\Arc\7-Zip")
    }
    
    For i,path in paths {
        Loop Files, %path%, D
        {
            fullpath=%A_LoopFileLongPath%\%exename%
            If (FileExist(fullpath))
                return fullpath
        }
    }
    
    Throw Exception("7-Zip not found",, exename)
}

Check7zDir(dir7z, exename := "7z.exe") {
    local ; Force-local mode
    dir7z:=RTrim(dir7z,"\")
    If (!dir7z)
        Throw Exception("Null path specified as directory")
    If (!FileExist(exe7z := dir7z "\" exename))
        Throw Exception("File not found in dir",, """" exename """ in """ dir7z """")
    return exe7z
}

find7zaexe(paths*) {
    paths.push(	  "\Distributives\Soft\PreInstalled\utils"
                , "D:\Distributives\Soft\PreInstalled\utils"
                , "\\localhost\Distributives\Soft\PreInstalled\utils"
                , "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
                , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
                , A_LineFile "\..\..\..\..\Soft\PreInstalled\utils")
    If (A_Is64bitOS)
        Try return find7zexe("7za64.exe", paths*)
    return find7zexe("7za.exe", paths*)
}

find7zGUIorAny(paths*) {
    Try return find7zexe("7zg.exe", paths*)
    Try return find7zexe("7z.exe", paths*)
    return find7zaexe(paths*)
}

findexe(exe, paths*) {
    local ; Force-local mode
    ; exe is name only or full path
    ; paths are additional full paths, dirs or path-masks to check for
    ; first check if executable is in %PATH%

    Loop Files, %exe%
	return A_LoopFileLongPath
    
    SplitPath exe, exename, , exeext
    If (exeext=="") {
	exe .= ".exe"
	exename .= ".exe"
    }
    
    Try return GetPathForFile(exe, paths*)
    
    Try {
	RegRead AppPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    Try {
	RegRead AppPath, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    EnvGet Path,PATH
    Try return GetPathForFile(exe, StrSplit(Path,";")*)
    
    EnvGet utilsdir,utilsdir
    If (utilsdir)
	Try return GetPathForFile(exe, utilsdir)
    
    ;Look for registered apps
    Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\Applications\" . exename)
    Loop Reg, HKEY_CLASSES_ROOT\, K
    {
	Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\" . A_LoopRegName)
    }
    
    Try return GetPathForFile(exe, A_LineFile "..\..\..\..\..\..\Distributives\Soft\PreInstalled\utils"
				 , A_LineFile "..\..\..\..\Programs"
				 , A_LineFile "..\..\..\..\Soft\PreInstalled\utils"
				 , A_LineFile "..\..\..\..\..\Distributives\Soft\PreInstalled\utils"
				 , "\Distributives\Soft\PreInstalled\utils"
				 , "\\localhost\Distributives\Soft\PreInstalled\utils" ) ; last resort, only works in office0

    EnvGet SystemDrive, SystemDrive
    EnvGet LocalAppData, LOCALAPPDATA
    EnvGet ProgramFilesx86, ProgramFiles(x86)
    For i, path in [SystemDrive "\SysUtils", LocalAppData "\Programs", A_ProgramFiles, ProgramFilesx86]
    Loop Files, %path%\%exename%, R
	return A_LoopFileLongPath
    
    Throw { Message: "Requested execuable not found", What: A_ThisFunc, Extra: exe }
}

GetPathForFile(file, paths*) {
    local ; Force-local mode
    For i,path in paths {
        ; Assume it's directory mask
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%file%
	    If (FileExist(fullpath))
		return fullpath
	}
	; Otherwise, it's full path-mask. If that only matches directories, Loop won't invoke single iteration (Loop Files, d:\Users\LogicDaemon\Downloads does nothing)
	Loop Files, %path%
            return A_LoopFileLongPath
    }
    
    Throw Exception("File not found",, file)
}

GetAppPathFromRegShellKey(ByRef exename, ByRef regsubKeyShell) {
    local ; Force-local mode
    regsubKey=%regsubKeyShell%\shell
    Loop Reg, %regsubKey%, K
    {
	RegRead regAppRun, %regsubKey%\%A_LoopRegName%\Command
	regpath := RemoveParameters(regAppRun)
	SplitPath regpath, regexe
	If (regexe = exename)
	    If (FileExist(regpath))
		return regpath
    }
    Throw Exception("Exename not found in specified shell key",, exename " in " regsubKeyShell)
}

RemoveParameters(ByRef runStr) {
    local ; Force-local mode
    QuotedFlag=0
    Loop Parse, runStr, %A_Space%
    {
	AppPathOnly .= A_LoopField
	IfInString A_LoopField, "
	    QuotedFlag:=!QuotedFlag
	If Not QuotedFlag
	    break
	AppPathOnly .= A_Space
    }
    return Trim(AppPathOnly, """")
}
