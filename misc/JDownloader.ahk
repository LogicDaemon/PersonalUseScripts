;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

args := ParseScriptCommandLine()

If (!args && WinExist("JDownloader 2 ahk_class SunAwtFrame")) {
    WinActivate
} Else {
    Run "%LocalAppData%\Programs\jdownloader\JDownloader.jar" %args%, %LocalAppData%\Programs\jdownloader
}

#include <ParseScriptCommandLine>
