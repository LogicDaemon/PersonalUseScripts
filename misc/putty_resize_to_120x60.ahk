;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If ( WinActive("cdn-jump.anymeeting.com - PuTTY") || WinActive("jnldev-va-2.serverpod.net - PuTTY") ) {
    WinMinimize
} Else {
    WinMove .* - PuTTY$ ahk_class ^PuTTY$ ahk_exe PUTTY\.EXE$,,,, 995, 1001
}
