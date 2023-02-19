#NoEnv

exeName = googledrivesync.exe
Process Exist, %exeName%
If (!ErrorLevel) {
    EnvGet UserProfile, USERPROFILE
    GoogleDriveRoot=%UserProfile%\Google Drive

    EnvGet ProgramFilesx86,ProgramFiles(x86)
    If (!ProgramFilesx86)
        EnvGet ProgramFilesx86,ProgramFiles
    If (!(exePath := FirstExisting(A_ProgramFiles "\Google\Drive\" exeName, ProgramFilesx86 "\Google\Drive\" exeName))) {
        Throw Exception(exeName " not found!")
        Exit
    }
    SplitPath exePath,, exeDir
    
    If (ShellRunWithBackgroundPriority(exePath, exeDir, "starting Backup and Sync from Google")) {
        WinWait Backup and Sync ahk_exe googledrivesync.exe
        ;SetProcesssesPriority("googledrivesync.exe", "B")
        Sleep 30000

        Run %comspec% /C "%GoogleDriveRoot%\Ограниченный доступ\mirror_shares.cmd",%GoogleDriveRoot%\Ограниченный доступ, Min
        RunAhkScriptIfExist(GoogleDriveRoot "\removeDesktopIni.ahk")
    }
}
ExitApp

RunAhkScriptIfExist(ByRef path, ByRef args := "") {
    If (FileExist(path)) {
        SplitPath path,, dir
        Run "%A_AhkPath%" "%path%" %args%, %dir%
    }
}

;#include <Affinity>
#include <FirstExisting>
#include <ShellRunWithBackgroundPriority>
