;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}
dest=d:\Program Files\OTP Siebel Web Client
system32=%A_WinDir%\System32
IfExist %A_WinDir%\SysWOW64
    system32=%A_WinDir%\SysWOW64

Run %comspec% /C "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd"

Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()


RunWait %exe7z% x -o"%dest%" -- "%A_ScriptDir%\OTP Siebel Web Client.7z"

RunWait "%system32%\wscript.exe" "%dest%\Binary.SetUID.vbs"

Loop Files, %dest%\*.dll
    RunWait %system32%\regsvr32.exe /s "%A_LoopFileFullPath%"

MsgBox Установлено.`n`nНадо импортировать от имени пользователя:`n"%dest%\bank.OTP.reg"`n"D:\Local_Scripts\IE\IE11Settings.reg"`n`nЯрлык на рабочем столе – "Сервисы сторонних компаний\Банк ОТП.lnk"

ExitApp

#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
