;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

release := JSON.Load(GetUrl("https://api.github.com/repos/zen-browser/desktop/releases/latest"))
For i, asset in release.assets {
    If (asset.name ~= "(?<!-arm64)\.exe") { ;"aria2-(?P<ver>.+)-win-(?P<arch>\d\dbit)-build(?P<buildNo>\d*)\.zip"
        SplitPath % asset.name,,, OutExtension, OutNameNoExt
        outFilename := OutNameNoExt "." release.tag_name "." OutExtension
        If (FileExist(A_ScriptDir "\" outFilename))
            timeCond := " -z """ A_ScriptDir "\" outFilename """"
        FileCreateDir %workdir%
        RunWait % "CURL -RLo""" workdir "\" outFilename """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" outFilename))
            FileMove % workdir "\" outFilename, % A_ScriptDir "\" outFilename, 1
    }
    FileRemoveDir %workdir%
}
ExitApp

#include <JSON>
