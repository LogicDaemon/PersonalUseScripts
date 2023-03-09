;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RunWait "%LocalAppData%\Programs\SysInternals\pssuspend64.exe" Widgets.exe,, Min
Loop
{
    Process Close, msedgewebview2.exe
} Until !ErrorLevel
