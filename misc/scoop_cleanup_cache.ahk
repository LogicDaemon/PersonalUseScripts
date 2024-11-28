;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance ignore
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

scoopBaseDir := FindScoopBaseDir()
scoopCacheDir := scoopBaseDir "\cache"
scoopAppsDir := scoopBaseDir "\apps"

oldVersionsDest := scoopCacheDir "\old\"
FileCreateDir % oldVersionsDest

noCleanupApps := {}
FileRead nocleanup_txt, % scoopCachedir "\_nocleanup.txt"
Loop Parse, nocleanup_txt, `n, `r
    noCleanupApps[A_LoopField] := ""
nocleanup_txt=

installedApps := {}
Loop Files, % scoopAppsDir "\*.*", D
{
    FileRead manifest_json, %A_LoopFileFullPath%\current\manifest.json
    manifest := JSON.Load(manifest_json)
    ver := manifest.version
    installedApps[A_LoopFileName] := ver
}

distribs := {}
Loop Files, % scoopCacheDir "\*.*"
{
    ; Filenames format: app#version#source_or_hash.ext
    ; examples:
    ; 7zip#24.07#https_www.7-zip.org_a_7z2407-x64.msi
    ; avidemux#2.8.1#6815d77.exe
    
    distParts := StrSplit(A_LoopFileName, "#")
    name := distParts[1]
    If noCleanupApps.HasKey(name)
        Continue
    version := distParts[2]
    other := distribs[name]
    If (other) {
        installedVer := installedApps[name]
        otherVer := other.ver
        If (VerCompare(version, ">" otherVer)) {
            ; if the other version is installed, don't delete it
            If (installedVer != otherVer) {
                For _, oname in other.fnames
                    FileMove % scoopCacheDir "\" oname, % oldVersionsDest oname
            }
        } Else {
            ; if the current version is installed, don't delete it
            If (installedVer && installedVer != version)
                FileMove % A_LoopFileFullPath, % oldVersionsDest A_LoopFileName
            Continue
        }
    }

    If (distribs[name].ver == version) {
        distribs[name].fnames.Push(A_LoopFileName)
    } Else {
        distribs[name] := { ver: "" version
                            , fnames: [A_LoopFileName] }
    }
}
Exit

#include <JSON>
#include <FindScoopBaseDir>
