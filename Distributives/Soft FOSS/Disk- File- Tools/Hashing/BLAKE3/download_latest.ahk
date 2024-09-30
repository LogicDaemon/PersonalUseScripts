;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

FileCreateDir %workdir%

releases_raw := GetUrl("https://api.github.com/repos/BLAKE3-team/BLAKE3/releases")
f := FileOpen(workdir "\releases.json", "w")
f.Write(releases_raw)
f.Close()

releases := JSON.Load(releases_raw)
releases_raw := ""

accept_branches :=  { "main": ""
                    , "master": ""
                    , "release": "" }

For _, release in releases {
    If (release.draft || release.prerelease || !accept_branches.HasKey(release.target_commitish))
        Continue
    For _, asset in release.assets {
        If (!EndsWith(asset.name, ".exe"))
            Continue
        If (FileExist(A_ScriptDir "\" asset.name))
            timeCond := " -z """ A_ScriptDir "\" asset.name """"
        RunWait % "CURL -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, % A_ScriptDir "\" asset.name, 1
        FileRemoveDir %workdir%
    }
    Break
}
ExitApp

EndsWith(long, short) {
    Return short == SubStr(long, 1-StrLen(short))
}

#include <JSON>
