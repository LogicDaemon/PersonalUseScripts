;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
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
