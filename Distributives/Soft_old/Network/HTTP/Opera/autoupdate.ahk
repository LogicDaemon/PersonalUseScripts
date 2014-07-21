#NoEnv

If A_OSVersion=WIN_2000 ;Newer Opera versions don't support Windows 2000
    Exit

Initial_WorkingDir = %A_WorkingDir%
DistSource=%A_ScriptDir%\autoupdate\*.i386.autoupdate.exe

Loop %DistSource%
    If ( A_LoopFileTimeCreated > LatestTime ) {
	LatestTime := A_LoopFileTimeCreated
	LatestDist := A_LoopFileFullPath
    }
If (!LatestDist) {
    LogMessage("Distributive not found", 1)
    ExitApp -1
}

;SplitPath, InputVar [, OutFileName, A_LoopFileDir, OutExtension, OutNameNoExt, OutDrive]
SplitPath LatestDist,LatestDistName,,,LatestDistNameNoExt

RegRead OperaInstallDirectory, HKEY_CURRENT_USER, Software\Opera Software, Last Install Path
If Not OperaInstallDirectory
{
    EnvGet ProgramFilesx86, ProgramFiles(x86)
    If ProgramFilesx86
	OperaInstallDirectory = %ProgramFilesx86%\Opera
    Else 
	OperaInstallDirectory = %ProgramFiles%\Opera
    IfNotExist %OperaInstallDirectory%
    {
	LogMessage("Didn't find nor Last Install Path in registry, nor %ProgramFiles%\Opera. Cannot continue, exiting.", 1)
	Exit 1
    }
}

TempDst = %OperaInstallDirectory%
;\%LatestDistNameNoExt%.tmp
FileCreateDir %TempDst%

LogMessage("Copying distributive " . LatestDistName . " to " . TempDst)
FileCopy %LatestDist%,%TempDst%,1
If ErrorLevel
{
    LogMessage("Error whilst copying: " . ErrorLevel, ErrorLevel)
    Exit %ErrorLevel%
}

LogMessage("Running " . TempDst . "\" . LatestDistName)
RunWait %TempDst%\%LatestDistName%,%TempDst%,UseErrorLevel
If ErrorLevel
    LogMessage("Error whilst running opera executable" . ErrorLevel, ErrorLevel)

LogMessage("Removing " . TempDst . "\" . LatestDistName)
FileDelete %TempDst%\%LatestDistName%
If ErrorLevel
    LogMessage("Can't remove leftover distributive file", ErrorLevel)

;FileMoveDir %TempDst%, %OperaInstallDirectory%, 2

If ErrorLevel
{
    SetWorkingDir %TempDst%
    If A_WorkingDir != %TempDst%
    {
	LogMessage("Changing working directory to " . TempDst . " failed, LastError: " . A_LastError, ErrorLevel)
	ExitApp 1
    }

    LogMessage("Moving directories")
    Loop *,2,1	;Only directories first
    {
	LogMessage("moving " . A_LoopFileFullPath)
	FileMoveDir %A_LoopFileFullPath%, %OperaInstallDirectory%%A_LoopFileFullPath%, 2
    }
    LogMessage("Moving files")
    Loop *,,1	;then only files
    {
	DstFName = %OperaInstallDirectory%%A_LoopFileFullPath%
	LogMessage("moving " . A_LoopFileFullPath . " to " . DstFName)
	
	FileMove %A_LoopFileFullPath%, %DstFName%, 1
	If ErrorLevel
	{
	    LogMessage("Error #" . ErrorLevel . " moving " . A_LoopFileFullPath . " to " . DstFName . ", renaming and Scheduling removing on reboot", 1)
	    NameUntilReboot = %DstFName%.delonreboot
    ;	FileMove %DstFName%, %NameUntilReboot%, 1
	    RenameResult := DllCall("MoveFileEx", "Str", DstFName, "Str", NameUntilReboot, "UInt", 1+8)
	    LogMessage("Renaming " . A_LoopFileLongPath . " Error #" . A_LastError, !RenameResult)
	    PendMoveResult := DllCall("MoveFileEx", "Str", NameUntilReboot , "Str", "", "UInt", 4)
	    LogMessage("PendMove " . NameUntilReboot . " Error #" . A_LastError, !PendMoveResult)
	    FileMove %A_LoopFileFullPath%, %DstFName%, 1
	    If ErrorLevel
	    {
		LogMessage("File " . A_LoopFileFullPath . " not installed", ErrorLevel)
		ExitError = 1
	    }
	}
    }
}
;FileRemoveDir %TempDst%,1

SetWorkingDir %Initial_WorkingDir%
Exit %ExitError%

LogMessage(errMsg, showMsgBox = 0) {
    EnvGet RunInteractiveInstalls,RunInteractiveInstalls
    If ( showMsgBox && ! ( RunInteractiveInstalls == "0" ) )
	MsgBox %errMsg% (#%showMsgBox%)
    FileAppend %errMsg% (#%showMsgBox%)`n, *, CP866
}
