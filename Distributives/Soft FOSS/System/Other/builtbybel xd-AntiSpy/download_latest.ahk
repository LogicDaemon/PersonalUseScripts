;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

release := JSON.Load(GetUrl("https://api.github.com/repos/builtbybel/xd-AntiSpy/releases/latest"))
release_name := release.name
destDir := A_ScriptDir "\" release_name
For i, asset in release.assets
    If (asset.name ~= "xd-AntiSpy.*\.zip") {
        FileCreateDir %destDir%  ; to avoid creating empty dir if no assets matching the regexp
        FileCreateDir %workdir%
        completeDlPath := destDir "\" asset.name
        If (FileExist(completeDlPath))
            timeCond := " -z """ completeDlPath """"
        RunWait % "CURL -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, % completeDlPath, 1
    }
    FileRemoveDir %workdir%
ExitApp

#include <JSON>
