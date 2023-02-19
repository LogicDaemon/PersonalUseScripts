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

#If (!WinExist("ahk_exe Greenshot.exe"))
^PrintScreen::
    If (!WinExist(ahk_exe SnippingTool.exe))
        RunDelayed(A_WinDir "\system32\SnippingTool.exe",,"")
    WinWait Snipping Tool ahk_class Microsoft-Windows-SnipperToolbar ahk_exe SnippingTool.exe
    Sleep 100
    WinActivate
    SendEvent !{vk4E} ; vk4E=N, !N
    ;ControlSend ToolbarWindow321, !{vk4E}
    ;ControlClick ToolbarWindow321, x30 y16
return
#If (GreenshotExe && !WinExist("ahk_exe Greenshot.exe"))
+PrintScreen::	RunDelayed(GreenshotExe,,"")
