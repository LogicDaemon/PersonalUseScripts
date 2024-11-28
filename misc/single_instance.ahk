;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

SplitPath 1, fileName
If WinExist("ahk_exe " fileName) {
    If WinActive("ahk_exe " fileName)
        WinActivateBottom ahk_exe %fileName%
    Else
        WinActivate
} Else {
    Run % ParseScriptCommandLine()
}

#include <ParseScriptCommandLine>
