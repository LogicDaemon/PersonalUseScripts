;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
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
