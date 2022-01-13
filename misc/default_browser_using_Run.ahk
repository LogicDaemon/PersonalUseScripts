;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

per_host_script := "default_browser." A_COMPUTERNAME ".ahk"

If (FileExist(per_host_script)) {
    RunWait % """" per_host_script """ " ParseScriptCommandLine()
} Else {
    Run https://
}

ExitApp

#include <ParseScriptCommandLine>
