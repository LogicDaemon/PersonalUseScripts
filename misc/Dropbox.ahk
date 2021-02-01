#NoEnv

exeDropboxfname := "Dropbox.exe"
Process Exist, %exeDropboxfname%
If ( !ErrorLevel ) { ; ErrorLevel = PID
    EnvGet ProgramFilesx86,ProgramFiles(x86)
    If (!ProgramFilesx86)
        ProgramFilesx86 := ProgramFiles
    If (!(exeDropbox := FirstExisting(A_AppData "\Dropbox\bin\" exeDropboxfname, ProgramFilesx86 "\Dropbox\Client\" exeDropboxfname))) {
        Throw Exception(exeDropboxfname " not found!")
        Exit
    }
    SplitPath exeDropbox,, dirDropbox
    ; /systemstartup
    If (ShellRunWithBackgroundPriority("""" exeDropbox """", dirDropbox, "starting Dropbox")) {
        Sleep 3000
        ;Affinity_Set(1, pid)
        
        ;Process Priority, ahk_pid %pid%, B
        Process Priority, DropboxUpdate.exe, Low
        
        For procpid, procpath in ProcessList() {
            SplitPath procpath, procexename
            If (procexename = "dropbox.exe")
                Process Priority, ahk_pid %procpid%, Low
            Else If (EndsWith(procexename, "\Dropbox\bin\QtWebEngineProcess.exe"))
                Process Priority, ahk_pid %procpid%, Normal
        }
    }
}

ExitApp

;#include <Affinity>
#include <FirstExisting>
#include <ProcessList>
#include <ShellRunWithBackgroundPriority>
