;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LocalAppData

ActivateOrRun("ahk_class Chrome_WidgetWin_1 ahk_exe Intermedia Unite.exe",, """" LocalAppData "\Programs\Intermedia Unite\Intermedia Unite.exe"" --update-channel fkdblnfdlkbncx", LocalAppData "\Programs\Intermedia Unite")
;(3) Welcome | AnyMeeting

cb := Clipboard
; https://anymeeting.com/vpetrenko
If (cb && RegExMatch(cb, "O)(?:(?:https?|anymeeting)://)?((?:www|meeting)\.)?(?P<meeting_linkpart>anymeeting(?:-.+)?\.com/[^\s]+)", m)) {
    Run % "anymeeting://" m.meeting_linkpart
}
ExitApp
