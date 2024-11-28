;print Autohotkey user's Lib directory path to stdout
;https://www.autohotkey.com/docs/v1/Functions.htm#lib
;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding cp1 ; OEM

FileAppend %A_MyDocuments%\AutoHotkey\Lib`n, *
