﻿;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

For i, asset in JSON.Load(GetUrl("https://api.github.com/repos/skeeto/w64devkit/releases/latest")).assets {
    ; w64devkit-1.20.0.zip
    If (asset.name ~= "w64devkit-(?P<ver>[\d\.]+\d)\.zip") {
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
