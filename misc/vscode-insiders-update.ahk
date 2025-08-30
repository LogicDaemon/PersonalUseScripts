#NoEnv
#SingleInstance
#Include <find7zexe>
#Warn

If (A_ScriptFullPath == A_LineFile) {
    DownloadAndUpdateVSCode("", "", True)
    Exit 0
}

#Include %A_LineFile%\..\vscode.lib.ahk
