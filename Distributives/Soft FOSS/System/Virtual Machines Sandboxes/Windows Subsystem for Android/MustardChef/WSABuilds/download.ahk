;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

ver=%1%
ver=Windows_11_2407.40000.4.0_v2
If (ver)
    var=tags/%ver%
Else
    ver=latest
rawData := GetUrl("https://api.github.com/repos/MustardChef/WSABuilds/releases/" ver)
varData := JSON.Load(rawData)
For i, asset in verData.assets {
    ; If (asset.name ~= "aria2-(?P<ver>.+)-win-(?P<arch>\d\dbit)-build(?P<buildNo>\d*)\.zip") {
    ; WSA_2407.40000.4.0_x64_Release-Nightly-GApps-13.0.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-GApps-13.0-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-NoGApps.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-KernelSU-v1.0.5-MindTheGapps-13.0-RemovedAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-29.0.29000.-stable-GApps-13.0.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-29.0.29000.-stable-NoGApps-NoAmazon.7z
    ; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-b1dc47a0.29001.-canary-GApps-13.0-NoAmazon.7z
    If (!RegExMatch(asset.name
                  , "^WSA_(?P<ver>[^_]+)_(?P<arch>[^_]+)"
                  . "_?(?P<namesuffix>.*)\.(?P<ext>\w+)$", m))
        Continue
    If (march != "x64")
        Continue
    If (!RegexMatch(mnamesuffix, "-with-(?P<oottype>\w+)-v?(?P<ootver>\d+(\..\w*)+)", r))
        Continue
    ;If (roottype != "magisk")
    ;    Continue
    ;If (!RegexMatch(mnamesuffix, "-(?P<apps>(No)?GApps)(-(?P<appsver>[^-]+))?", g))
    ;    Continue
    ;If (gapps != "GApps")
    ;    Continue
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
    tmpPath := workdir "\" asset.name
    destDir := A_ScriptDir "\" verData.tag_name
    destPath := destDir "\" asset.name
    timeCond := FileExist(destPath) ? " -z """ destPath """" : ""
    dlCmd := "curl -RLo""" tmpPath """" timeCond " """ asset.browser_download_url """"
    logPath=%tmpPath%\.log
    RunWait %ComSpec% /C ""%dlCmd%" >"%logPath%" 2>&1", %workdir%, Hide UseErrorLevel
    If (ErrorLevel) {
        FileAppend `n%A_Now% error %ErrorLevel%`n, %logPath%
    } Else {
        FileDelete %logPath%
        If (FileExist(tmpPath)) {
            FileCreateDir %destDir%
            FileMove %tmpPath%, %destPath%, 1
        }
        FileRemoveDir %workdir%
    }
}
If (!asset) {
    MsgBox, 16, Error, No suitable assets found!
}
ExitApp

#include <JSON>
