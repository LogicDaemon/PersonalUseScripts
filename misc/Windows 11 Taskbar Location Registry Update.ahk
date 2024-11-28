;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; https://allthings.how/how-to-move-taskbar-to-top-on-windows-11/

taskbarPos := MoveTaskbar()
taskbarLeftSelected := (taskbarPos == "00") ? "Checked" : ""
taskbarTopSelected := (taskbarPos == "01") ? "Checked" : ""
taskbarRightSelected := (taskbarPos == "02") ? "Checked" : ""
taskbarBottomSelected := (taskbarPos == "03") ? "Checked" : ""

Gui Add, Radio, xm  y40 w30 h20 gTaskbarLocationLeft %taskbarLeftSelected%, ←
Gui Add, Radio, x40 ym  w30 h20 gTaskbarLocationTop %taskbarTopSelected%, ↑
Gui Add, Radio, x80 y40 w30 h20 gTaskbarLocationRight %taskbarRightSelected%, →
Gui Add, Radio, x40 y80 w30 h20 gTaskbarLocationBottom %taskbarBottomSelected%, ↓
Gui Show
Exit

; GuiEvent=Normal
; EventInfo=0
TaskbarLocationLeft(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    MoveTaskbar("00")
}
TaskbarLocationTop(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    MoveTaskbar("01")
}
TaskbarLocationRight(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    MoveTaskbar("02")
}
TaskbarLocationBottom(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    MoveTaskbar("03")
}

MoveTaskbar(newRect := "") {
    global SystemRoot
    RegRead v, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings
    ;   1  4   8   12  16  20  24  28  32  36  40  44  48  52  56  60  64  68  72  76  80  84  88  92
    ;   ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  
    ; v=30000000FEFFFFFF7AF40000030000003E000000300000000000000070050000700D0000A00500006000000001000000
    ;                           ^^ this is the taskbar location byte
    ; 00: Move the taskbar to the left of the screen
    ; 01: Move the taskbar to the top of the screen
    ; 02: Move the taskbar to the right side of the screen
    ; 03: Move the taskbar to the bottom of the screen (default)
    currentRect := SubStr(v,25,2)
    If (newRect == "") {
        return currentRect
    }
    newRect := SubStr("00" newRect, -1)
    if (newRect == currentRect) {
        return currentRect
    }
    v := SubStr(v,1,24) newRect SubStr(v,27)
    RegWrite REG_BINARY, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings, %v%
    Process Close, explorer.exe
    Run %SystemRoot%\explorer.exe
}

GuiClose:
GuiEscape:
    ExitApp
