;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

For i, asset in JSON.Load(GetUrl("https://api.github.com/repos/YT-Advanced/WSA-Script/releases/latest")).assets {
    ; If (asset.name ~= "aria2-(?P<ver>.+)-win-(?P<arch>\d\dbit)-build(?P<buildNo>\d*)\.zip") {
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-with-magisk-28.1(28100)-stable-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-with-KernelSU-v1.0.2-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-KernelSU-v1.0.2-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-28.1(28100)-stable-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-with-KernelSU-v1.0.2-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_arm64_Release-Nightly-with-magisk-28.1(28100)-stable-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-28.1(28100)-stable-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-KernelSU-v1.0.2-GApps-13.0-NoAmazon.7z
    ; x64 = 
    If (!RegExMatch(asset.name
                  , "^WSA_(?P<ver>[^_]+)_(?P<arch>[^_]+)"
                  . "_?(?P<namesuffix>.*)\.(?P<ext>\w+)$", m))
        Continue
    If (march != "x64")
        Continue
    If (!RegexMatch(mnamesuffix, "-with-(?P<oottype>\w+)-v?(?P<ootver>\d+(\..\w*)+)", r))
        Continue
    If (roottype != "magisk")
        Continue
    If (!RegexMatch(mnamesuffix, "-(?P<apps>(No)?GApps)(-(?P<appsver>[^-]+))?", g))
        Continue
    If (gapps != "GApps")
        Continue
    ; MsgBox % asset.name
    ;         . "`nver: " mver
    ;         . "`narch: " march
    ;         . "`nreleasetype: " mreleasetype
    ;         . "`nroottype: " mroottype
    ;         . "`nrootver: " mrootver
    ;         . "`ngapps: " mgapps
    ;         . "`ngappsver: " mgappsver
    ;         . "`nnamesuffix: " mnamesuffix
    ;         . "`next: " mext
    FileCreateDir %workdir%
    If (FileExist(A_ScriptDir "\" asset.name))
        timeCond := " -z """ A_ScriptDir "\" asset.name """"
    dlCmd := "curl -RLo""" workdir "\" asset.name """" timeCond " """ asset.browser_download_url """"
    logPath := workdir "\" asset.name ".log"
    RunWait % ComSpec " /C """ dlCmd " >""" logPath """ 2>&1""", %workdir%, Hide UseErrorLevel
    If (ErrorLevel) {
        FileAppend % "`n" A_Now " error " ErrorLevel "`n", %logPath%
    } Else {
        FileDelete %logPath%
        If (FileExist(workdir "\" asset.name))
            FileMove % workdir "\" asset.name, % A_ScriptDir "\" asset.name, 1
        FileRemoveDir %workdir%
    }
}
ExitApp

#include <JSON>
