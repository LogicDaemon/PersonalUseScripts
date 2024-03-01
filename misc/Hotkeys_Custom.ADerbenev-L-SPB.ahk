Loop 16
    FileRead hot_password%A_Index%, %LocalAppData%\_sec\hp%A_Index%.txt

If (ReadPassesFromFile(CmdlArgs(1)[1]))
    return

Run "%A_AhkPath%" "%A_ScriptDir%\KeePass_%A_UserName%.ahk"

ShowGUI()
return

ButtonOK:
GuiSubmit:
    Gui Submit
GuiEscape:
GuiClose:
    Gui Destroy
    ;save a bit on memory if Windows 5 or newer - MilesAhead
    DllCall("psapi.dll\EmptyWorkingSet", "Int", -1, "Int")
return

ShowGUI() {
    Global hot_password1, hot_password2, hot_password3
    For i, v in ["ROOT", "IMEX1", "Prod"] {
        Gui Add, Text, Section xm, %v%
        Gui Add, Edit, ys x80 vhot_password%i% Password, % hot_password%i%
    }
    Gui Add, Button, Section xm Default, OK
    Gui Show
}

ReadPassesFromFile(fname := "*") {
    global hot_password1, hot_password2, hot_password3
    If (!fname)
        return
    ; linesread := StrSplit(ReadSlowly(fname), "`n", "`r")
    passwordsCount := 0
    Loop Parse, % ReadSlowly(fname), `n, `r
        hot_password%A_Index% := A_LoopField, passwordsCount += !!A_LoopField
    Until A_Index >= 3
    return passwordsCount == 3
}

CustomReload() {
    global hot_password1, hot_password2, hot_password3
    Exec := RunWithStdin( A_AhkPath " """ A_ScriptDir "\Hotkeys_Reload_Intermediary.ahk"" *" ; "*" indicates that password should be read from stdin
                        , hot_password1 "`n" hot_password2 "`n" hot_password3 )
    Sleep 500
    return true
}

#PgUp::         Volume_Up
#PgDn::         Volume_Down

#IfWinActive ahk_exe WinAuth.exe
    #!VK4C::        SendRaw %hot_password4%       ;vk4C=l #!l
#IfWinActive
#!VK4C::        SendRaw %hot_password1% ;vk4C=l #!l
#!+VK4C::       SendRaw %hot_password2% ;vk4C=l #!+l
#!^VK4C::       SendRaw %hot_password3% ;vk4C=l #!^l

#VK55:: Run "%A_AhkPath%" "%A_ScriptDir%\Unite.ahk" ; #u
