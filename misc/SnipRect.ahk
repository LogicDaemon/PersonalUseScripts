;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Run ms-screenclip:

;GroupAdd st, ahk_exe SnippingTool.exe

;RunDelayed([A_WinDir "\system32\SnippingTool.exe", "/clip"])
;If (!WinExist("ahk_group st")) {
    ;4 Open the application with its window at its most recent size and position. The active window remains active.
;    ShellRun(A_WinDir "\system32\SnippingTool.exe",,,, 4)
;}
;WinWait ahk_group st
;ControlSend ToolbarWindow321, !n
;ControlClick X45 Y55

;#include <ShellRun by Lexikos>
