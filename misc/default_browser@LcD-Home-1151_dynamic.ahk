;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

Run % """" A_AhkPath """ """ A_ScriptDir "\Vivaldi.ahk"" " ParseScriptCommandLine()
ExitApp

#include <ParseScriptCommandLine>
