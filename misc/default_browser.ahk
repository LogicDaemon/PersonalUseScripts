;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

If (!FileExist(A_ScriptDir "\default_browser." A_COMPUTERNAME ".ahk")) {
    Run https://
    ExitApp
}

#include *i %A_ScriptDir%\default_browser.%A_COMPUTERNAME%.ahk
