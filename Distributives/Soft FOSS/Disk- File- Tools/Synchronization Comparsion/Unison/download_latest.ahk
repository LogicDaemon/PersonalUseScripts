;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

For i, asset in JSON.Load(GetUrl("https://api.github.com/repos/bcpierce00/unison/releases/latest")).assets
    If (asset.name ~= "unison-v.+\.windows\.zip") {
;unison-v2.51.4_rc2+ocaml-4.12.0+x86_64.windows.zip
;unison-v2.51.4_rc2+ocaml-4.10.1+i386.windows.zip
        FileCreateDir %workdir%
        If (FileExist(A_ScriptDir "\" asset.name))
            timeCond := " -z """ A_ScriptDir "\" asset.name """"
        RunWait % "CURL -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, % A_ScriptDir "\" asset.name, 1
    }
    FileRemoveDir %workdir%
ExitApp

#include <JSON>
