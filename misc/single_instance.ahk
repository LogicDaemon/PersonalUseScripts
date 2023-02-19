;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
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
