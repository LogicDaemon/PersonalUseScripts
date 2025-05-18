#NoEnv
#SingleInstance force
#KeyHistory 0

SendMode Input
ReadData()
Exit

#IfWinActive ahk_exe Warframe.x64.exe
#!F1::
#!F2::
#!F3::
#!F4::
    PrepareLogin(SubStr(A_ThisHotkey, 0))
#!+F1::
#!+F2::
#!+F3::
#!+F4::
    SendLoginPassword(SubStr(A_ThisHotkey, 0))
Exit
>!F4:: Run taskmgr.exe
#IfWinActive

PrepareLogin(index) {
    Local
    
    WinGetPos X, Y, Width, Height, ahk_exe Warframe.x64.exe
    mid_w := Width // 2
    mid_h := Height // 2
    click_x := mid_w + 0.25 * Min(Width, Height) + 350
    click_y := mid_h + 25
    MouseMove 0, 0
    Sleep 300
    Send {Click -%Width% -%Height%}
    Sleep 500
    Send {Down}
    Sleep 1500
    Send {Right}
    Sleep 500
    Send {Click}
    Sleep 100
}

SendLoginPassword(index) {
    Local
    data := ReadData()
    parts := StrSplit(data[index], A_Tab)
    last := parts.MaxIndex()
    For i, part in parts {
        SendRaw % part
        If (i < last) {
            Send {Tab}
            Sleep 100
        }
    }
}

ReadData() {
    Local
    Static data := ""
    If (data)
        Return data
    data := []

    EnvGet LocalAppData, LOCALAPPDATA
    Loop Read, % LocalAppData "\_sec\warframe.txt", `n, `r
    {
        parts := StrSplit(A_LoopReadLine, A_Tab)
        pw := parts[2]
        If (SubStr(pw, 0) == "*") {
            pw := SubStr(pw, 1, -1)
            data.Push(parts[1] A_Tab pw "-pwd-" pw)
        } Else {
            data.Push(A_LoopReadLine)
        }
    }
    Return data
}
