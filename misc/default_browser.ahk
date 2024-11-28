;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

If (!FileExist(A_ScriptDir "\default_browser@" A_ComputerName ".ahk")) {
    Run https:
    ExitApp
}

#include *i %A_ScriptDir%\default_browser@%A_ComputerName%.ahk
