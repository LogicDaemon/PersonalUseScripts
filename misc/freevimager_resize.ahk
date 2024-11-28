;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8
Thread Interrupt, -1

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

#IfWinActive FreeVimager - [ ahk_exe FreeVimager.exe
^+VK52:: Resize() ; vk52=r ^+r
^+VK53:: SaveAs() ; vk53=s ^+s
#IfWinActive

Resize() {
    ; WinGetTitle title, A
    ; FreeVimager - [D:\Users\LogicDaemon\Pictures\Sorted Photos\Тбилиси\IMG_20220514_200908.jpg , 282/459 , 4640x3472 RGB24 , 9.1MB]
    WinWaitActive FreeVimager - [
    Loop
    {
        KeyWait VK52
        ; KeyWait Shift
        ControlSend,, ^R
        WinWaitActive Resizing ahk_class #32770 ahk_exe FreeVimager.exe,, 1
        If (ErrorLevel) {
            ToolTip Resize dialog not found
            Continue
        }
        If (A_Index > 1)
            ToolTip
        break
    }
    ControlSetText Edit2, 1440
    ControlFocus OK
    Sleep 50
    ; ControlClick OK ; Button1
    ControlSend OK, {Enter}
}

SaveAs() {
    WinMenuSelectItem A,, File, Save As...
}
