;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

#NoEnv

Loop %2%
{
    RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%1%,, %A_LoopFileLongPath%
    SplitPath A_LoopFileLongPath, , FilePath
    RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%1%, Path, %FilePath%
}
