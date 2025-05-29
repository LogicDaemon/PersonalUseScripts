;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"
For i, asset in JSON.Load(GetURL("https://api.github.com/repos/aloneguid/bt/releases/latest")).assets {
    ; bt-4.3.0.zip bt-4.3.0.msi bt-4.3.0.msi.sha256.txt bt-4.3.0.zip.sha256.txt
    If (asset.name ~= "^bt-(?P<ver>[\d\.]+\d)\.(zip|msi)(\.sha256\.txt)?$") {
        FileCreateDir %workdir%
        If (FileExist(A_ScriptDir "\" asset.name))
            timeCond := " -z """ A_ScriptDir "\" asset.name """"
        RunWait % "CURL -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, % A_ScriptDir "\" asset.name, 1
    }
    FileRemoveDir %workdir%
}
ExitApp

#include <JSON>
#include <GetURL>
