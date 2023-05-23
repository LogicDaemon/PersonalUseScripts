;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

GroupAdd jumpnet, jnldev-va-2.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd cdnjump, cdn-jump.anymeeting.com - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE

WaitForSubnet(IMVPNSubnets()) ;wait for VPN connection
Run "%LocalAppData%\Programs\putty\PAGEANT.EXE" "%LocalAppData%\_sec\aderbenev-rsa-key-20210414.ppk"
Process Wait, PAGEANT.EXE

If (WinExist("ahk_group jumpnet")) {
    WinActivate
} Else {
    Run "%LocalAppData%\Programs\putty\PUTTY.EXE" -load "jnldev-va-2.serverpod.net" -N
    WinWait ahk_group jumpnet
}
Loop
{
    WinWaitNotActive
    WinGet state, MinMax
} Until state == -1 or state == "" ; "" means the window doesn't exist

If (WinExist("ahk_group cdnjump")) {
    WinActivate
} Else {
    Run "%LocalAppData%\Programs\putty\PUTTY.EXE" -load "cdn-jump" -N
}

Exitapp 0

#include %A_ScriptDir%\wait_for_vpn_ip_prefix.ahk
