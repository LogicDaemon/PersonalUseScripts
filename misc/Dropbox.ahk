#NoEnv

FindDropboxExe() {
    Local
    For rootKey in ["HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE"] {
        RegRead dropboxBinDir, %rootKey%\Software\Dropbox, InstallPath
        If (dropboxBinDir)
            Return dropboxBinDir "\Dropbox.exe"
    }

    EnvGet ProgramFilesx86,ProgramFiles(x86)
    If (!ProgramFilesx86)
        ProgramFilesx86 := ProgramFiles
    If ((exeDropbox := FirstExisting(A_AppData "\Dropbox\bin\Dropbox.exe", ProgramFilesx86 "\Dropbox\Client\Dropbox.exe"))) {
        Return exeDropbox
    }
    Throw Exception("Dropbox.exe not found!")
}

StartDropbox() {
    Local
    Process Exist, Dropbox.exe ; ErrorLevel = PID
    If ( ErrorLevel )
        Return
    exeDropbox := FindDropboxExe()
    
    ; /systemstartup
    If (!ShellRunWithBackgroundPriority("""" exeDropbox """", dirDropbox, "starting Dropbox"))
        Throw Exception("Failed to start Dropbox")
    Sleep 3000
    ;Affinity_Set(1, pid)
    
    ;Process Priority, ahk_pid %pid%, B
    Process Priority, DropboxUpdate.exe, Low
    
    For procpid, procpath in ProcessList() {
        SplitPath procpath, procexename
        If procexename in Dropbox.exe,DropboxUpdate.exe,DropboxCrashHandler.exe
            SetEfficiencyMode(procpid)
        Else If (EndsWith(procexename, "\Dropbox\bin\QtWebEngineProcess.exe"))
            Process Priority, ahk_pid %procpid%, Normal
    }
}

If (A_LineFile == A_ScriptFullPath) {
    StartDropbox()
    ExitApp
}

;#include <Affinity>
#include <FirstExisting>
#include <ProcessList>
#include <ShellRunWithBackgroundPriority>
#include <SetEfficiencyMode>
