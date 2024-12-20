﻿;This script puts all command line arguments to clibroard
;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
#SingleInstance force

If ( %0% > 0 ) {
    Loop %0%  ; For each parameter:
	AllArguments .= ( A_Index > 1 ? "`r`n" : "") . %A_Index%
    Clipboard = %AllArguments%
    ToolTip Скопировано путей: %0%
} Else {
    MsgBox 68, %A_ScriptName%, This script copies command line arguments to clipboard. Intended to be used as Send To target`, so shourtcut to one should be in Send To.`n`nCreate the shourtcut?
    IfMsgBox Yes
    {
	EnvGet UserProfile, UserProfile
	FileCreateShortcut %A_AhkPath%, %UserProfile%\SendTo\Names to Clipboard.lnk,, %A_ScriptFullPath%, Copies file names (with paths) to clipboard.
    }
}

Sleep 1500
