;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

msedgeRunKeys := {}

runKey = HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run

Loop Reg, %runKey%
{
    If (!(A_LoopRegName ~= "^MicrosoftEdgeAutoLaunch_"))
        Continue

    RegRead v
    If (SubStr(v, 1, 1) == "_")
        Continue

    msedgeRunKeys[A_LoopRegName] := v
}

For k, v in msedgeRunKeys {
    RegWrite REG_SZ, %runKey%, %k%, _%v%
}
