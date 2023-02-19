;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If ( WinActive("cdn-jump.anymeeting.com - PuTTY") || WinActive("jnldev-va-2.serverpod.net - PuTTY") ) {
    WinMinimize
} Else {
    WinMove .* - PuTTY$ ahk_class ^PuTTY$ ahk_exe PUTTY\.EXE$,,,, 995, 1001
}
