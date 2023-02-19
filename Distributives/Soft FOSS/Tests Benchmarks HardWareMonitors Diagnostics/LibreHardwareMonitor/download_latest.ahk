;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8
#include *i <find7zexe>

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet workdir,workdir

If (!workdir)
    workdir := A_ScriptDir "\temp"

For i, asset in JSON.Load(GetUrl("https://api.github.com/repos/LibreHardwareMonitor/LibreHardwareMonitor/releases/latest")).assets
    ; If (asset.name ~= "aria2-(?P<ver>.+)-win-(?P<arch>\d\dbit)-build(?P<buildNo>\d*)\.zip") {
    SplitPath % asset.name, , , ext, name
    FileCreateDir %workdir%
    latest_time := 0
    Loop Files, %A_ScriptDir%\%name%-*.%ext%
    {
        If (A_LoopFileTimeModified > latest_time) {
            latest_time := A_LoopFileTimeModified
            latest_path := A_LoopFileFullPath
        }
    }
    If (latest_path)
        timeCond := " -z """ latest_path """"
    workdistpath := workdir "\" asset.name
    RunWait % "CURL -RLo""" workdistpath """" timeCond " """ asset.browser_download_url """", %workdir%, Min UseErrorLevel
    If (FileExist(workdistpath)) {
        RunWait %exe7z% x -aoa -y -o"%workdir%\test-ver" -- "%workdistpath%" LibreHardwareMonitor.exe, %workdir%, Min UseErrorLevel
        If (!ErrorLevel) {
            FileGetVersion ver, %workdir%\test-ver\LibreHardwareMonitor.exe
            FileMove % workdistpath, % A_ScriptDir "\" name "-" ver "." ext, 1
        }
    }
    FileRemoveDir %workdir%, 1
ExitApp

#include <JSON>
