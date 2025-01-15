;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (WinActive("FreeVimager - ahk_exe FreeVimager.exe")) {
    Run "%A_AhkPath%" "%A_ScriptDir%\freevimager_resize.ahk"
} Else {
    Run "%A_AhkPath%" "%A_ScriptDir%\LiceCapResize.ahk"
}
