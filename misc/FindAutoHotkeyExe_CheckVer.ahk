#NoEnv
If A_AhkVersion >= 1.1.33
    ExitApp 0
; sometimes it's required to return specific error level
a=%1%
If a
    ExitApp %a%
ExitApp 1
