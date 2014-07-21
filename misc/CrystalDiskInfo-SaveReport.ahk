;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

exesuffix := A_Is64bitOS ? "64" : "32"
Loop Files, %LocalAppData%\Programs\CrystalDiskInfo*, D
{
    Run "%A_LoopFileFullPath%\DiskInfo%exesuffix%.exe" /CopyExit, %A_LoopFileFullPath%
    break
}
