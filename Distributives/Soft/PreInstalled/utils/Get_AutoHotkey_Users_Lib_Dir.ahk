;print Autohotkey user's Lib directory path to stdout
;https://www.autohotkey.com/docs/v1/Functions.htm#lib
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding cp1 ; OEM

FileAppend %A_MyDocuments%\AutoHotkey\Lib`n, *
