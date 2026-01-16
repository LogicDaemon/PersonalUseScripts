;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

GetDropboxDir(startDropboxWaitms := 10000) {
    Local
    Global LocalAppData, JSON
    If (LocalAppData)
        lLocalAppData := LocalAppData
    Else
        EnvGet lLocalAppData, LocalAppData
    pathDropboxinfo = %lLocalAppData%\Dropbox\info.json
    If (!FileExist(pathDropboxinfo))
        Throw Exception("Dropbox\info.json not found",,pathDropboxinfo)
    FileRead dropboxInfoJson, *P65001 %pathDropboxinfo% ; 65001 = utf-8, see http://msdn.microsoft.com/en-us/library/dd317756.aspx
    dropboxDir := JSON.Load(dropboxInfoJson).personal.path
    If (!dropboxDir)
        Throw Exception("Failed to find .personal.path in Dropbox\info.json",,dropboxInfoJson)

    If (startDropboxWaitms) {
        TrayTip,, Starting Dropbox
        Process Exist, dropbox.exe
        If (!ErrorLevel) {
            RunWait "%A_AhkPath%" "%A_ScriptDir%\Dropbox.ahk"
            Sleep %startDropboxWaitms%
        }
    }

    Return dropboxDir
}

#include <JSON>
