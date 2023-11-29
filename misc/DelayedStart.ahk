;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

delay_s=%1%
command=%2%
If (!delay_s || !command)
    MsgBox Usage: "%A_ScriptName%" <delay in seconds> <command to execute>

cmdlPrms := -1
delay_arg := ParseScriptCommandLine(cmdlPrms)

Sleep delay_s * 1000
Run %cmdlPrms%
