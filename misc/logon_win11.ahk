;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RunWait "%LocalAppData%\Programs\SysInternals\pssuspend64.exe" Widgets.exe,, Min
Loop
{
    Process Close, msedgewebview2.exe
} Until !ErrorLevel
