#NoEnv
#SingleInstance force

DetectHiddenWindows On
DetectHiddenText On
SetTitleMatchMode RegEx

SetTimer NoMoreWait, -300000

Run "%1%" /silent /allusers, , , OutputVarPID

WinWait ahk_pid %OutputVarPID%,, 5
WinWaitClose ahk_pid %OutputVarPID%,, 180
;ahk_pid %OutputVarPID% is ahk_class #32770

GroupAdd Opera, - Opera$ ahk_class ^OperaWindowClass$
GroupAdd Opera, ^Добро пожаловать$ ahk_class ^OperaWindowClass$
GroupAdd Opera, Welcome to Opera ahk_class OperaWindowClass

GroupAdd Opera, ^Opera$ ahk_class ^#32770$
;, ^Error initializing Opera: module 10 \(locale\)

WinWait ahk_group Opera
Sleep 100

;WinGet ProcessName, ProcessName
;WinGetTitle Title
;WinGetText Text
;WinGetClass class
;MsgBox %ProcessName%: %Title% ahk_class %class%`n%Text%
;WinWait ahk_group waits for all windows in group


IfWinExist Usage Statistics ahk_class OperaWindowClass
{
    WinClose
}

Sleep 100

IfWinExist ^Opera$ ahk_class ^#32770$, ^Error initializing Opera: module 10 (locale)$
{
    WM_LBUTTONUP = 0x202
    SendMessage, WM_LBUTTONUP, , , Button1
}
WinClose ahk_class ^OperaWindowClass$,, 15
IfWinNotExist ahk_class ^OperaWindowClass$, Exit

NoMoreWait:
    WinClose ahk_class ^OperaWindowClass$,, 15
    Process Close, opera.exe
ExitApp
