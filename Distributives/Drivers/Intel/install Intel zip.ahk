#NoEnv
global exe7z
find7zfunc:="find7zexe"
If(IsFunc(find7zfunc)) {
    Try exe7z:=%find7zfunc%("7zg.exe")
    If (!exe7z) {
	Try exe7z:=%find7zfunc%()
	If (!exe7z) {
	    find7zfunc:="find7zaexe"
	    exe7z:=%find7zfunc%()
	}
    }
} Else {
    FileSelectFile exe7z, 3, 7z.exe, Путь к исполняемому файлу 7-Zip (7z.exe`, 7zg.exe либо 7za.exe), Portable Executable (*.exe)
}
If (!exe7z)
    ExitApp

Menu Tray, Tip, Installing Intel Zip

; 1st argument is always archive name
; 2nd arg could be either another archive (and so on) or 1st argument for setup executable

global LocalDistributivesDrive="d:"

;if not A_IsAdmin
;{
;    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
;    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
;    Exit
;}

if %0%
{
    zipname=%1%
    If %2%
    {
	IfExist %2%
	{
	    Loop %0%
		InstallLatestByMask(%A_Index%)
	} Else {
	    CommandLine := DllCall( "GetCommandLine", "Str" )
	    ExecCommand := SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+2)
	    args := SubStr(ExecCommand, InStr(ExecCommand,zipname,1)+StrLen(zipname)+2)
	    InstallLatestByMask(zipname, args)
	}
    } Else {
	InstallLatestByMask(zipname)
    }
} Else {
    MsgBox В качестве аргументов необходимо передать названия (или маски) файлов`, которые необходимо установить.
}

Exit

InstallLatestByMask(path,args="") {
    Loop %path%
	If ( A_LoopFileTimeModified > LatestTimeFound )
	    LatestArchive := A_LoopFileLongPath, LatestTimeFound := A_LoopFileTimeModified
    If args
	Install(LatestArchive,args)
    Else
	Install(LatestArchive)
}

Install(FullPathtoSrcZip,args="") {
    static CurrentScriptCopied=0
    
    IfNotExist %FullPathtoSrcZip%
	MsgBox Source %FullPathtoSrcZip% not found!

    If (!CurrentScriptCopied) {
	SplitPath A_ScriptDir, , , , , ScriptDrive
	ThisScriptLocalDistPath := LocalDistributivesDrive . SubStr(A_ScriptDir, StrLen(ScriptDrive)+1)
	FileCreateDir %ThisScriptLocalDistPath%
	IfExist %ThisScriptLocalDistPath%\.
	    FileCopy %A_ScriptFullPath%, %ThisScriptLocalDistPath%, 1
	CurrentScriptCopied=1
    }
    
    SplitPath FullPathtoSrcZip, SrcZipName, SrcZipDir, , SrcZipNamewoExt, SrcZipDrive
    LocalDistPath := LocalDistributivesDrive . SubStr(SrcZipDir, StrLen(SrcZipDrive)+1)
    FileCreateDir %LocalDistPath%
    IfExist %LocalDistPath%\.
    {
	FileCopy %SrcZipDir%\*.ahk, %LocalDistPath%, 1
	FileCopy %SrcZipDir%\*.cmd, %LocalDistPath%, 1
	FileCopy %FullPathtoSrcZip%, %LocalDistPath%, 1
	If Not ErrorLevel
	{
	    SplitPath FullPathtoSrcZip, SrcZipFName
	    FullPathtoSrcZip = %LocalDistPath%\%SrcZipFName%
	}
    }

    TempExtractPath=%A_Temp%\%A_ScriptName% %SrcZipNamewoExt%
    RunWait "%exe7z%" x -aoa -y -o"%TempExtractPath%" -- "%FullPathtoSrcZip%",,UseErrorLevel

    If ErrorLevel=ERROR
	RunWait "\Distributives\Soft\PreInstalled\utils\7za.exe" x -aoa -y -o"%TempExtractPath%" -- "%FullPathtoSrcZip%",,UseErrorLevel

    If ErrorLevel=ERROR
	RunWait "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\7za.exe" x -aoa -y -o"%TempExtractPath%" -- "%FullPathtoSrcZip%",,UseErrorLevel
	
    If ErrorLevel=ERROR
	MsgBox Error starting 7za.exe
    Else If ErrorLevel
	MsgBox Error %ErrorLevel% unpacking archive:`n%FullPathtoSrcZip%
    
    If (ErrorLevel) {
	MsgBox Cannot find 7-Zip to unpack the archive. Giving up.
	return
    }

    IfNotExist %A_WinDir%\Logs
	FileCreateDir %A_WinDir%\Logs
    
    Loop %TempExtractPath%\SetupChipset.exe, 0, 1 ; newer inf driver has different executable name and command line arguments
    {
	SetupPath=%A_LoopFileLongPath%
	SetupDir=%A_LoopFileDir%
	If Not args
	    args=-s -norestart
;	    -log "%A_WinDir%\Logs\%SrcZipNamewoExt% Install.log"
    }
    If Not SetupPath
	Loop %TempExtractPath%\Setup.exe, 0, 1
	{
	    SetupPath=%A_LoopFileLongPath%
	    SetupDir=%A_LoopFileDir%
	    If Not args
		args=-s -overwrite -report "%A_WinDir%\Logs\%SrcZipNamewoExt% Install.log"
	}
    
    If SetupPath
    {
	TrayTip Installing Intel Zip, Running %SetupPath%
	RunWait "%SetupPath%" %args%,%SetupDir%,UseErrorLevel
	Sleep 3000

	; 14 = reboot required, 5 = no matching devices found
	If ErrorLevel in ,0,5,14
	    FileRemoveDir %TempExtractPath%, 1
	Else
	    MsgBox Installer exited with errorlevel %ERRORLEVEL%
    } Else {
	MsgBox Not found Setup executable
    }
}

#include *i \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk

;https://communities.intel.com/message/165076
;Exit code (%ERRORLEVEL%)	Value in log file	Meaning
;0	0x0	Success
;1	0xA001	Bad command line
;2	0xA002	User is not an administrator
;3	0xA003	The OS is not supported for this product
;5	0xA005	No devices were found that matched package INF files
;7	0xA007	User refused a driver downgrade
;9	0xA009	User canceled the installation
;10	0xA00A	Another install is already active
;11	0xA00B	Error while extracting files
;12	0xA00C	Nothing to do
;13	0xA00D	A system restart is needed before setup can continue
;14	0xA00E	Setup has completed successfully but a system restart is required
;15	0xA00F	Setup has completed successfully and a system restart has been initiated
;16	0xA010	Bad installation path
;17	0xA011	Error while installing driver
;255	Win32 error code	General install failure
