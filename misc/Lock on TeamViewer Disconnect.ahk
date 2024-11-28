;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

GroupAdd tvpanel, Панель TeamViewer ahk_class TV_ServerControl ahk_exe TeamViewer.exe
If (WinExist("ahk_group tvpanel")) {
    WinWaitClose ahk_group tvpanel
    Run %SystemRoot%\System32\tsdiscon.exe
} Else {
    MsgBox TeamViewer не подключен
}
