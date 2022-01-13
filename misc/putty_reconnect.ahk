;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

GroupAdd puttyinactivemainwindow, PuTTY (inactive) ahk_class PuTTY ahk_exe PUTTY.EXE
GroupAdd puttyreconnectmsgbox, PuTTY Fatal Error ahk_class #32770 ahk_exe PUTTY.EXE, Network error: Connection refused
GroupAdd puttyreconnectmsgbox, PuTTY Fatal Error ahk_class #32770 ahk_exe PUTTY.EXE, Network error: Software caused connection abort
GroupAdd puttyreconnectmsgbox, PuTTY Fatal Error ahk_class #32770 ahk_exe PUTTY.EXE, Remote side unexpectedly closed network connection

While ( WinExist("ahk_group puttyreconnectmsgbox") ) {
    ControlClick OK
}
While ( WinExist("ahk_group puttyinactivemainwindow") ) {
    WinActivateBottom ahk_group puttyinactivemainwindow
    WinMenuSelectItem ,,, 0&, &Restart Session
}
