;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

#include *i <find7zexe>

If (!exe7z)
    exe7z := A_ProgramFiles . "\7-Zip\7zG.exe"

;VarSetCapacity(LocalAppData,(A_IsUnicode ? 2 : 1)*1025) 

;LocalAppDataID:=28
;r := DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", LocalAppDataID, "int", 0 , "uint", 0 , "str" , LocalAppData) 
;If (r || ErrorLevel) {
;    MsgBox r: %r%; ErrorLevel: %ErrorLevel%
;    Exit
;}

EnvGet LocalAppData,LocalAppData
ChromiumPath=%LocalAppData%\Programs\Chromium
;%ChromiumPath%\chrome-win is temporary directory, it must not exist usually
If (FileExist(ChromiumPath . "\chrome-win"))
    FileRemoveDir %ChromiumPath%\chrome-win, 1

DistrRelDir=Distributives\Soft FOSS\Network\HTTP\Chromium
CheckDistRoots=D:,\\miwifi.com
Loop Parse, CheckDistRoots,CSV
    If FileExist(A_LoopField "\" DistrRelDir) {
	DistributivePathToDir=%A_LoopField%\%DistrRelDir%
	break
    }
If (!DistributivePathToDir) {
    MsgBox %DistrRelDir% not found in %CheckDistRoots%. Fix the script.
    Exit
}

For i, osSuffix in (A_Is64bitOS ? ["64", ""] : [""]) {
    DistributivePathToArchive=%DistributivePathToDir%\chrome-win%osSuffix%.zip
} Until found := FileExist(DistributivePathToArchive)

If (!found)
    TrayMsgAndExit("Distributive Path not accessible:`n" . DistributivePathToArchive, 3)
TrayTip Updating chromium, DistributivePathToArchive: %DistributivePathToArchive%`nRunning distributive downloader…,3
RunWait %comspec% /C "%DistributivePathToDir%\download.cmd", %DistributivePathToDir%, Min
;If (ErrorLevel)
;    TrayMsgAndExit("Downloading error", 1)

TrayTip Updating chromium, Extracting file to check version…
testfile=chrome.exe
FileCreateDir %ChromiumPath%
SetWorkingDir %ChromiumPath%
If (ErrorLevel)
    Throw Exception("Could not change current directory",, ChromiumPath)
RunWait "%exe7z%" x -y "%DistributivePathToArchive%" "chrome-win\%testfile%", %ChromiumPath%, Min UseErrorLevel

FileGetTime NewChromeBuildTime, %ChromiumPath%\chrome-win\%testfile%
If (!NewChromeBuildTime)
    Throw Exception("Can't get time of """ ChromiumPath "\chrome-win\" testfile """")
FileGetVersion ver, %ChromiumPath%\chrome-win\%testfile%

TrayTip Updating chromium, New Version %ver%-%NewChromeBuildTime%
DestVerFullPath=%ChromiumPath%\%ver%-%NewChromeBuildTime%

If (FileExist(DestVerFullPath)) {
    FileRemoveDir %ChromiumPath%\chrome-win, 1
    TrayMsgAndExit("Current version is the same as in the distributive`n" . ver . " - " . NewChromeBuildTime, 1)
}

TrayTip Updating chromium, Extracting new version %ver%-%NewChromeBuildTime%
RunWait "%exe7z%" x -aoa -o"%ChromiumPath%" -- "%DistributivePathToArchive%", %A_Temp%, Min
If (!ErrorLevel) {
    FileMoveDir %ChromiumPath%\chrome-win, %DestVerFullPath%, R
    If (ErrorLevel) {
	TrayMsgAndExit("Update failed`, cannot rename `n" . ChromiumPath . "\chrome-win`n to `n" . ver,3)
    } Else {
	latestpath=%ChromiumPath%\current
	;ChromiumStartCommand="%A_AhkPath%" %A_ScriptDir%\Chromium.ahk
	ChromiumStartCommand="%latestpath%\chrome.exe"
	FileRemoveDir %latestpath%
	RunWait %comspec% /C "MKLINK /J "%latestpath%" "%DestVerFullPath%"",,Min
	; using %ChromiumPath%\Google-Chrome-Google-Chrome-Chromium.ico instead of original "%latestpath%\chrome.exe"
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\Capabilities, ApplicationIcon, %ChromiumPath%\Google-Chrome-Google-Chrome-Chromium.ico`,0
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\DefaultIcon, , %ChromiumPath%\Google-Chrome-Google-Chrome-Chromium.ico`,0
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\InstallInfo, HideIconsCommand, %ChromiumStartCommand% --hide-icons
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\InstallInfo, ReinstallCommand, %ChromiumStartCommand% --make-default-browser
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\InstallInfo, ShowIconsCommand, %ChromiumStartCommand% --show-icons
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Chromium\shell\open\command, , %ChromiumStartCommand%
	
	Run %A_WinDir%\System32\compact.exe /c /f /s /i /exe:lzx,%DestVerFullPath%,Hide
    }
}

TrayMsgAndExit(msg, opt="") {
    FileRemoveDir %ChromiumPath%\chrome-win, 1
    TrayTip Updating chromium, %msg%, , %opt%
    Sleep 3000
    ExitApp
}
