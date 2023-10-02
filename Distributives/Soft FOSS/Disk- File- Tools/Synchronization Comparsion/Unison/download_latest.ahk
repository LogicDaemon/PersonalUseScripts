;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

latestAssetsRaw := GetUrl("https://api.github.com/repos/bcpierce00/unison/releases/latest")
For i, asset in JSON.Load(latestAssetsRaw).assets {
    If (asset.name ~= "unison-.+[\.\-]windows(-\w+)?\.zip") {
        relPath := StrReplace(RegExReplace(asset.browser_download_url, "^\w+://", ""), "/", "\")
        SplitPath relPath,, subDir
        FileCreateDir %A_ScriptDir%\%subDir%
        dlDest := A_ScriptDir "\" subDir "\" asset.name
        
        ;unison-2.53.3-windows-i386.zip
        ;unison-v2.51.4_rc2+ocaml-4.12.0+x86_64.windows.zip
        ;unison-v2.51.4_rc2+ocaml-4.10.1+i386.windows.zip
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
