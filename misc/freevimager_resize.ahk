;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8
Thread Interrupt, -1

SetTitleMatchMode Regex

GroupAdd fvi, ^FreeVimager - ahk_exe \\FreeVimager(-.*)?\.exe$
GroupAdd fvir, ^Resizing ahk_class #32770 ahk_exe \\FreeVimager(-.*)?\.exe$

#IfWinActive ahk_group fvi
^+VK52:: Resize() ; vk52=r ^+r
^+VK53:: SaveAs() ; vk53=s ^+s
#IfWinActive

Resize() {
    Local
    Static MAX_WH := [3440, 1440]
    WinGetTitle title, A
    ; FreeVimager ≥9
    ; FreeVimager - [D:\Users\LogicDaemon\Pictures\Sorted Photos\Тбилиси\IMG_20220514_200908.jpg , 282/459 , 4640x3472 RGB24 , 9.1MB]
    dimensions := RegExMatch(title, ", (\d+x\d+) \w+ , [\d.]+\wB( \*)?\]", m)
    If (!dimensions) {
        ; FreeVimager 7.7.0
        ; FreeVimager - [IMG_20160306_112323_HDR.jpg , File 3 of 3 in Directory, 4160x3120 , RGB24 , File: 2091 KB]
        dimensions := RegExMatch(title, ", (\d+x\d+) , \w+", m)
    }
    If (!dimensions) {
        MsgBox Failed to get dimensions from title:`n%title%
        Return
    }
    ; MsgBox Title: %title%`nDimensions: %m1%
    wh := StrSplit(m1, "x",, 2)
    ; invert limits if portrait
    limit_WH := wh[2] <= wh[1] ? MAX_WH : [MAX_WH[2], MAX_WH[1]]

    If (wh[1] <= limit_WH[1] && wh[2] <= limit_WH[2]) {
        ToolTip Smaller than limits already.
        Sleep 1000
        ToolTip
        Return
    }

    Loop
    {
        WinWaitActive ahk_group fvi,, 1
        ControlSend,, ^R
        WinWaitActive ahk_group fvir,, 1
        If (ErrorLevel) {
            ToolTip Resize dialog not found [%A_Index%]
            Continue
        }
        If (A_Index > 1)
            ToolTip
        break
    }

    If (wh[1] / limit_WH[1] > wh[2] / limit_WH[2]) {
        ; width is the limiting factor
        ControlSetText Edit1, % limit_WH[1]
    } Else {
        ; height is the limiting factor
        ControlSetText Edit2, % limit_WH[2]
    }

    ControlFocus OK
    Sleep 50
    ; ControlClick OK ; Button1
    ControlSend OK, {Enter}
}

SaveAs() {
    WinMenuSelectItem A,, File, Save As...
}
