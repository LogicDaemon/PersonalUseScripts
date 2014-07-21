;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#SingleInstance force
FileEncoding UTF-8
SetTitleMatchMode RegEx

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

SysGet SM_CYCAPTION, 4
SysGet SM_CXSIZEFRAME, 32
SysGet SM_CYSIZEFRAME, 33
;LICEcap v1.26 [stopped] ahk_class #32770 ahk_exe licecap.exe
;Record...
;Stop
;Max FPS:
;Size:
;x
GroupAdd LiceCapMain, ^LICEcap .*\[stopped\] ahk_class ^\#32770$ ahk_exe \\licecap\.exe$, Record\.\.\.
;LICEcap [recording] ahk_class #32770 ahk_exe licecap.exe
;2019-07-14.gif - LICEcap [recording] ahk_class #32770 ahk_exe licecap.exe
;[pause]
;Stop
;1026x1025 GIF 0:54 @ 7.4fps
GroupAdd LiceCapMainRecording, LICEcap.* \[recording\] ahk_class ^\#32770$ ahk_exe \\licecap\.exe$, \[pause\]
;PREROLL: 3 - 2019-07-14.gif - LICEcap ahk_class #32770 ahk_exe licecap.exe
GroupAdd LiceCapMainRecording, ^PREROLL: \d+ - .+ - LICEcap ahk_class ^\#32770$ ahk_exe \\licecap\.exe$

While (!WinExist("ahk_exe \\licecap\.exe$")) {
    activeWin := WinExist("A")
    Run "%LocalAppData%\Programs\LICEcap\licecap.exe"
    WinWait ahk_exe \\licecap\.exe$
    WinActivate ahk_id %activeWin%
}

Loop
{
    If (WinActive("ahk_exe \\licecap\.exe$")) {
        ToolTip Waiting for non-licecap window
        WinWaitNotActive 
        ToolTip
    }
    
    If (!WinExist("ahk_exe \\licecap\.exe$"))
        ExitApp
    
    If (!(activeWin := WinExist("A"))) ; fails if ,,"ahk_exe \\licecap\.exe$"
        ExitApp
    ;captured	x: 164	y: 140	w: 1434	h: 825
    ;LiceCap	x: 156	y: 102	w: 1448	h: 891
    ;               -8     -38       +8    +66 (58 w/o frame)
    WinGetPos cX, cY, cW, cH, ahk_id %activeWin%
    WinMove ahk_group LiceCapMain,, cX-SM_CXSIZEFRAME+1, cY-SM_CYSIZEFRAME-SM_CYSIZEFRAME-SM_CYCAPTION+1, cW+SM_CXSIZEFRAME, cH+SM_CYSIZEFRAME+58
    ControlClick Record..., ahk_group LiceCapMain ; Button2, but it switches to [pause] when recording is going
    ; Save window appears
    WinWait ^Choose file for recording$ ahk_class ^\#32770$ ahk_exe \\licecap\.exe$
    WinWaitClose
    WinWaitActive ^LICEcap ahk_exe \\licecap\.exe$,, 1
    ; PREROLL: 
    
    WinWait ahk_group LiceCapMainRecording,,1
    If (!ErrorLevel) { ; if recording starts, this will appear
        If (WinActive())
            WinActivate ahk_id %activeWin%
        ; wait for the recording to stop
        WinWaitClose ahk_group LiceCapMainRecording
        ;WinWaitActive ahk_group LiceCapMain
    }
    ; but save may be cancelled
}
