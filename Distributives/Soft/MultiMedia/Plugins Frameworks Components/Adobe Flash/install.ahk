;Install Adobe Flash Player NPAPI Plugin and/or ActiveX
; usage:
; install.ahk [swtich [swtich […]]]
; switch: /[no]flag OR -[no]flag
; each switch sets a flag to 1 (true) without "no", or to 0 (false) with "no"
; Available flags:
;RunInteractiveInstalls	- if not 0, asks for elevation of privilegies if needed, and message boxes shown with queries to install components and set settings.
;			  if 0, script runs completely non-interactive.
;InstallActiveX		- run Install of ActiveX component. If not specified, it's only run if an older version is currently installed
;InstallPlugin		- run Install of NPAPI plugin component. If not specified, it's only run if an older version is currently installed
;SetSystemSettings	- unregisters NPSWF32.dll and removes AdobeFlashPlayerUpdateSvc service and fixes HKCR\MIME. 0 by default. 
;
; example: install.ahk /InstallActiveX /NoRunInteractiveInstalls
; 	InstallActiveX always installed, NPAPI Plugin in only installed if it's already installed, but older version than current distributive, and no are not modified by script (updater)
; example: install.ahk /NoRunInteractiveInstalls /SetSystemSettings
; 	both ActiveX and NPAPI plugins updated (only if already installed) and flash updater removed from system.

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

PathPlugin=%A_WinDir%\system32\Macromed\Flash\NPSWF32.dll
PathPluginDistMask=%A_ScriptDir%\install_flash_player_*_plugin.exe
PathActiveX=%A_WinDir%\system32\Macromed\Flash\Flash11e.ocx
PathActiveXDistMask=%A_ScriptDir%\install*active_x.exe
FlashPlayerFilesLocation=%A_WinDir%\system32\Macromed\Flash

If %0%
{
    RunInteractiveInstalls=0
    Loop %0%
    {
	If (SkipNext=1) {
	    SkipNext=0
	    continue
	}
	arg:=%A_Index%
	FlagMarker:=SubStr(arg,1,1)
	If FlagMarker in /,-
	{
	    CurrentSwitch:=SubStr(arg,2)
	    FlagPrefix:=SubStr(CurrentSwitch,1,2)
	    If FlagPrefix=No
	    {
		FlagSwitchTo=0
		CurrentSwitch:=SubStr(CurrentSwitch,3)
	    } Else FlagSwitchTo=1
	    
	    If CurrentSwitch in InstallActiveX,InstallPlugin,SetSystemSettings,RunInteractiveInstalls
		%CurrentSwitch%=%FlagSwitchTo%

	    Else If CurrentSwitch=InteractiveInstall
		RunInteractiveInstalls:=FlagSwitchTo

	    Else If CurrentSwitch in Plugin,ActiveX
	    {
		Install%CurrentSwitch%=%FlagSwitchTo%
		If (FlagSwitchTo=1) {
		    NextArgNo:=A_Index+1
		    DistMask:=%NextArgNo%
		    Path%CurrentSwitch%DistMask=DistMask
		    SkipNext=1
		}
	    }
	} Else
	    Throw Exception("Invalid command line argument", 0, arg)
    }
} Else {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!=0 && !A_IsAdmin) {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

FileGetVersion VerActiveX, %PathActiveX%
FileGetVersion VerPlugin, %PathDll%

Loop %PathActiveXDistMask%
    PathActiveXDist=%A_LoopFileFullPath%
If PathActiveXDist
    FileGetVersion VerActiveXDist, %PathActiveXDist%

Loop %PathPluginDistMask%
    PathPluginDist=%A_LoopFileFullPath%
If PathPluginDist
    FileGetVersion VerPluginDist, %PathPluginDist%

InstallActiveX := InstallActiveX || VerActiveX!="" && VerActiveXDist!="" && VerActiveXDist>VerActiveX
InstallPlugin := InstallPlugin || VerPlugin!="" && VerPluginDist!="" && VerPluginDist>VerPlugin

If (RunInteractiveInstalls!=0) {
    TrayTip Установка Adobe Flash, Сейчас установлены:`nActiveX: %VerActiveX%`nPlugin: %VerPlugin%`n`nИмеются дистрибутивы:`nActiveX: %VerActiveXDist%`nPlugin: %VerPluginDist%
    If (!InstallActiveX) {
	If (!InstallPlugin)
	    MsgNotInstalled=ни компонент ActiveX`, ни плагин.`nУстановить и то`, и другое?
	Else
	    MsgNotInstalled=компонент ActiveX`nУстановить? Иначе (при ответе Нет) будет только обновлён плагин.
    } Else If (!InstallPlugin)
	MsgNotInstalled=`nУстановить плагин? Иначе (при ответе Нет) будет только обновлён компонент ActiveX.

    MsgBox 35, Установка Adobe Flash, Сейчас на компьютере не установлен %MsgNotInstalled%
    IfMsgBox Cancel
	Exit
    IfMsgBox Yes
    {
	InstallActiveX=1
	InstallPlugin=1
    }
    IfMsgBox No
	If (!(InstallActiveX || InstallPlugin)) {
	    MsgBox 36, Установка Adobe Flash, Установить ActiveX?
	    IfMsgBox Yes
		InstallActiveX=1
	    MsgBox 36, Установка Adobe Flash, Установить плагин?
	    IfMsgBox Yes
		InstallPlugin=1
	}
}

If InstallActiveX
    RunWait "%PathActiveXDist%" -install
If InstallPlugin
    RunWait "%PathPluginDist%" -install

If (InstallActiveX || InstallPlugin) {
    If (SetSystemSettings=="" && RunInteractiveInstalls!=0) {
	MsgTextMore=
	If A_OSVersion in XP,2000
	    MsgTextMore=`nКроме того`, при установке на Windows 2000/XP Adobe Flash портит параметры безопасности ключа HKCR\MIME. Они также будут исправлены.
	MsgBox 36, Установка Adobe Flash, Adobe Flash устанавливает специальную службу`, которая скачивает и предлагает установить обновления. Удалить её?%MsgTextMore%
	IfMsgBox Yes
	    SetSystemSettings=1
    }

    If (SetSystemSettings==1) {
	IfExist %FlashPlayerFilesLocation%\NPSWF32.dll
	    Run regsvr32.exe /u /s NPSWF32.dll, %FlashPlayerFilesLocation%, Hide
	RunWait sc.exe STOP AdobeFlashPlayerUpdateSvc,,Hide
	Sleep 5000
	RuNWait sc.exe DELETE AdobeFlashPlayerUpdateSvc,,Hide
    ;        REM Delete updater
    ;        cacls "*.exe" /E /R Everyone
    ;        cacls "*.exe" /E /R Все
    ;        cacls "*.exe" /E /G Everyone:F
    ;        cacls "*.exe" /E /G Все:F
    ;        ATTRIB -R "*.*"
    ;        DEL "*.exe"

	RunWait schtasks.exe /DELETE /TN "Adobe Flash Player Updater" /F,, Hide
	If A_OSVersion in XP,2000
	    RunWait %comspec% /C "%A_ScriptDir%\Reset_HKCR_MIME_ACL.cmd",, Hide
    }
}
