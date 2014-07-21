;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    paths := Object()
    Loop %0%
	If (A_Index==1)
	    exe := %A_Index%
	Else
	    paths[A_Index-1] := %A_Index%
    
    If(exe) {
	Try {
	    fullpath := findexe(exe,paths*)
	    FileAppend %fullpath%`n, *, CP1
	    ExitApp 0
	} Catch err {
;	    MsgBox % "Error " . err.Message  . " in " . err.What . ", extra: " . err.Extra
	    FileAppend % "Error """ . err.Message  . """ in " . err.What . ", extra: " . err.Extra . "`n", **, CP1
	    ExitApp 1
	}
    } Else {
	FileAppend No exe-name specified`n,**,CP1
	ExitApp 32767
    }
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
