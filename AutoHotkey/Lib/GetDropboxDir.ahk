;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

GetDropboxDir(ByRef checkDropboxRunning := -1) {
    local
    global LocalAppData, JSON
    If (LocalAppData)
        lLocalAppData := LocalAppData
    Else
        EnvGet lLocalAppData, LocalAppData
    pathDropboxinfo = %lLocalAppData%\Dropbox\info.json

    If (!FileExist(pathDropboxinfo))
        Throw Exception("Dropbox\info.json not found",,pathDropboxinfo)
    If (checkDropboxRunning) {
        Process Exist, dropbox.exe
        If (!(checkDropboxRunning := ErrorLevel)) {
            TrayTip,, Starting Dropbox
            RunWait "%A_AhkPath%" "%A_ScriptDir%\Dropbox.ahk",,,checkDropboxRunning
            Sleep 5000
        }
    }

    FileRead dropboxInfoJson, *P65001 %pathDropboxinfo% ; 65001 = utf-8, see http://msdn.microsoft.com/en-us/library/dd317756.aspx
    dropboxInfo := JSON.Load(dropboxInfoJson)
    For accType, accInfo in dropboxInfo
        If (dropboxDir := accInfo.path)
            return dropboxDir
    Throw Exception("path Not found in Dropbox\info.json",,dropboxInfo)
}

#include <JSON>
