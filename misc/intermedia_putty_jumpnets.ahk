;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet SecretDataDir,SecretDataDir
EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

GroupAdd proxy1080, jnldev-va-2.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd proxy1080, jnldev-wa-2.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd proxy1080, 10.112.202.208 - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd proxy1080, jnldev-va-am-media.serverpod.net - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd proxy1080, 10.216.209.49 - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd cdnjump, cdn-jump.anymeeting.com - PuTTY ahk_class PuTTY ahk_exe PUTTY.EXE

WaitForSubnet(IMVPNSubnets()) ;wait for VPN connection
Run PAGEANT.EXE "%SecretDataDir%\aderbenev-rsa-key-20210414.ppk"
Process Wait, PAGEANT.EXE

If (WinExist("ahk_group proxy1080")) {
    WinActivate
} Else {
    Run PUTTY.EXE -load "jnldev-wa-2.serverpod.net" -N
    ;Run PUTTY.EXE -load "jnldev-va-am-media.serverpod.net" -N
    WinWait ahk_group proxy1080
}
;Loop
;{
;    WinWaitNotActive
;    WinGet state, MinMax
;} Until state == -1 or state == "" ; "" means the window doesn't exist

;If (WinExist("ahk_group cdnjump")) {
;    WinActivate
;} Else {
;    Run "%LocalAppData%\Programs\putty\PUTTY.EXE" -load "cdn-jump" -N
;}

Exitapp 0

#include %A_ScriptDir%\wait_for_vpn_ip_prefix.ahk
