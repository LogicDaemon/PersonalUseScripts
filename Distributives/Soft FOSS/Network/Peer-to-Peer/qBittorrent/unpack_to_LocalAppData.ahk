;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

If (!A_Is64bitOS)
    Throw Exception("The script only knows name of the 64-bit qBittorrent distributive.")

latestTime := ""
Loop Files, %A_ScriptDir%\qbittorrent_*_x64_setup.exe
    If (A_LoopFileTimeModified > latestTime)
        latestTime := A_LoopFileTimeModified, latestDist := A_LoopFileLongPath
Exit InstallDistToLocalAppData("qBittorrent", latestDist,,, "-x!*.pdb -x!$PLUGINSDIR -x!uninst.exe -x!translations")

#include <InstallDistToLocalAppData>
