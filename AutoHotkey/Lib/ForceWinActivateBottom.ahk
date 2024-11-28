;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ForceWinActivateBottom(ByRef WinTitle:="", ByRef WinText:="", ByRef ExcludeTitle:="", ByRef ExcludeText:="") {
    WinSet AlwaysOnTop, On, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    Sleep 0
    WinSet AlwaysOnTop, Off
    WinActivateBottom %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
