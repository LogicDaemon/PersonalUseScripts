;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

latestAssetsRaw := GetUrl("https://api.github.com/repos/ITachiLab/hotkey-detective/releases/latest")
For i, asset in JSON.Load(latestAssetsRaw).assets {
    If (asset.name ~= "hotkey-detective-((\d+\.)*\d+).zip") {
        relPath := StrReplace(RegExReplace(asset.browser_download_url, "^\w+://", ""), "/", "\")
        SplitPath relPath,, subDir
        FileCreateDir %A_ScriptDir%\%subDir%
        dlDest := A_ScriptDir "\" subDir "\" asset.name
        
        FileCreateDir %workdir%
        If (FileExist(dlDest))
            timeCond := " -z """ dlDest """"
        RunWait % "CURL -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, %dlDest%, 1
    }
    FileRemoveDir %workdir%
    f := FileOpen(A_ScriptDir "\latest_assets.json", 1, "UTF-8-RAW")
    f.Write(latestAssetsRaw)
    f.Close()
    Run COMPACT.EXE /C /EXE:LZX "%A_ScriptDir%\latest_assets.json",, Min
}
ExitApp

#include <JSON>
