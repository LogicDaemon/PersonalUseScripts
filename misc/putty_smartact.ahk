;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#NoTrayIcon
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

SetTitleMatchMode RegEx

If (WinActive(" - PuTTY$ ahk_class ^PuTTY$ ahk_exe PUTTY\.EXE$") || WinActive("@ ahk_class ^PuTTY$ ahk_exe PUTTY\.EXE$")) {
    main_putty_window_active := true
    If (WinActive("^(cdn-jump\.anymeeting\.com|jnldev-va-2\.serverpod\.net)")) {
        WinMinimize
    } Else {
        sizes := [[995, 1001], [675, 425]]
        WinGetPos X, Y, w, h
        For i, sz in sizes {
            If (w==sz[1] && h==sz[2]) {
                ri := i == 1 ? sizes.Length() : i-1
                WinMove,,,,, sizes[ri][1], sizes[ri][2]
                resized := true
                break
            }
        }
        If (resized) {
            ToolTip % "Found window " w "×" h "`, resized to " sizes[ri][1] "×" sizes[ri][2]
            Sleep 1000
        } Else {
            ToolTip size %w%×%h% not in list
            WinMove,,,,, sizes[1][1], sizes[1][2]
            Sleep 3000
        }
    }
} Else {
    If (WinExist("^PuTTY Fatal Error$ ahk_class ^#32770$ ahk_exe PUTTY\.EXE$")) {
        Run "%A_AhkPath%" "%A_ScriptDir%\putty_reconnect.ahk"
    } Else {
        WinActivate ahk_class PuTTY ahk_exe PUTTY\.EXE
    }
}

ExitApp
