;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

Run % """" A_AhkPath """ """ A_ScriptDir "\Vivaldi.ahk"" " ParseScriptCommandLine()
ExitApp

#include <ParseScriptCommandLine>
