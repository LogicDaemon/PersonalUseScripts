;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LocalAppData

ActivateOrRun("ahk_class Chrome_WidgetWin_1 ahk_exe Intermedia Unite.exe",, """" LocalAppData "\Programs\Intermedia Unite\Intermedia Unite.exe"" --update-channel fkdblnfdlkbncx", LocalAppData "\Programs\Intermedia Unite")
;(3) Welcome | AnyMeeting
