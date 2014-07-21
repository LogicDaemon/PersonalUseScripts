;TeamViewer Fullscreen
#IfWinActive .+ TeamViewer ahk_class TV_CClientWindowClass
#!Enter::
    WinWait .+ TeamViewer ahk_class TV_CClientWindowClass
    ; Center - 75px
    WinGetPos,,,Width
    XLoc := Width/2 - 125
    ControlClick X%XLoc% Y45
    ;~ ATL:00A7DCE01
    ControlSend ,, {Down 2}{Enter}{Up}{Enter}
    Sleep 200
    WinSet AlwaysOnTop, Off
    ControlSend ahk_class TV_CClientWindowClass, {ScrollLock}
    PostMessage 0x112, 0xF120,,, ahk_class TV_CClientWindowClass ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
return
