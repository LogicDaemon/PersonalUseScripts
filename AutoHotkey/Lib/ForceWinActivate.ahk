;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

ForceWinActivate(ByRef WinTitle:="", ByRef WinText:="", ByRef ExcludeTitle:="", ByRef ExcludeText:="") {
    WinSet AlwaysOnTop, On, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    Sleep 0
    WinSet AlwaysOnTop, Off
    WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
