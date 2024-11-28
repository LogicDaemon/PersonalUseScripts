;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
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
ExitApp %ErrorLevel%
