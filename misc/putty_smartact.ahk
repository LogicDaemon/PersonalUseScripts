;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

SetTitleMatchMode RegEx

GroupAdd puttyWindow, ahk_class ^PuTTY$
GroupAdd puttyMainWindow, @ ahk_class ^PuTTY$
GroupAdd puttyMainWindow, - PuTTY$ ahk_class ^PuTTY$,,,^(cdn-jump\.anymeeting\.com|jnldev-va-2\.serverpod\.net)
GroupAdd puttyInactiveMainWindow, ^PuTTY \(inactive\)$ ahk_class ^PuTTY$
GroupAdd puttyJumpboxWindow, ^jnldev-va-2\.serverpod\.net - PuTTY$ ahk_class ^PuTTY$
GroupAdd puttyJumpnetOrCdnJumpWindow, ^(cdn-jump\.anymeeting\.com|jnldev-va-2\.serverpod\.net) - PuTTY$ ahk_class ^PuTTY$
GroupAdd puttyReconnectMsgBox, ^PuTTY Fatal Error$ ahk_class ^#32770$, Network error: Software caused connection abort
GroupAdd puttyReconnectMsgBox, ^PuTTY Fatal Error$ ahk_class ^#32770$, Network error: Connection refused
GroupAdd puttyReconnectMsgBox, ^PuTTY Fatal Error$ ahk_class ^#32770$, Remote side unexpectedly closed network connection

If (WinActive("ahk_group puttyReconnectMsgBox") || WinActive("ahk_group puttyInactiveMainWindow")) {
    Reconnect()
}

If (WinActive("ahk_group puttyMainWindow")) {
    If (WinActive("^(cdn-jump\.anymeeting\.com|jnldev-va-2\.serverpod\.net)")) {
        WinMinimize
    } Else {
        ResizeWindow()
    }
} Else If (WinExist("ahk_group puttyReconnectMsgBox")) {
        Reconnect()
} Else If (WinActive("ahk_group puttyWindow")) {
        WinActivateBottom ahk_group puttyWindow
} Else {
        WinActivate ahk_group puttyWindow
}

ExitApp

Esc::
ExitApp

Reconnect() {
    While WinExist("ahk_group puttyReconnectMsgBox") {
        ControlClick OK
    }
    While WinExist("ahk_group puttyInactiveMainWindow") {
        While WinExist("ahk_group puttyInactiveMainWindow") {
            WinActivateBottom ahk_group puttyInactiveMainWindow
            WinMenuSelectItem ,,, 0&, &Restart Session
        }
        
        WinWait ahk_group puttyJumpboxWindow,, 1
        If (ErrorLevel) ; none of windows are of the jumpnet
            break
        ; jumpnet ssh window exists, activate it after the reconnect
        WinActivate

        Loop
        {
            ; wait until user minimizes it or switches away before proceeding.
            WinWaitNotActive ahk_group puttyJumpboxWindow
            ; Or it might be some other window stealing the focus because it failed to reconnect
            If (WinActive("ahk_group puttyReconnectMsgBox")) {
                ControlClick OK
            } Else {
                break
            }
        }
        
        ; then try reconnecting remaining windows again
    }
}

ResizeWindow() {
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
