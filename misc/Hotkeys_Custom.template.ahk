hotkeys_custom_ahk := A_LineFile
If (ReadPassesFromFile(CmdlArgs(1)[1]))
    return

Run "%A_AhkPath%" "%A_ScriptDir%\KeePass_%A_UserName%.ahk"

Gui Add, Text, Section, Main pass:
Gui Add, Edit, ys x80 vhot_password Password, %hot_password%
Gui Add, Text, Section xm, 2nd pass:
Gui Add, Edit, ys x80 vhot2_password Password, %hot2_password%
Gui Add, Button, Section xm Default, OK
Gui Show
; InputBox, hot_password,,, HIDE
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

ReadPassesFromFile(fname := "*") {
    global hot_password, hot2_password
    If (!fname)
        return
    linesread := StrSplit(ReadSlowly(fname), "`n", "`r")
    If (!IsObject(linesread))
        return
    hot_password := linesRead[1], hot2_password := linesRead[2]
    return hot2_password
}

CustomReload() {
    global hot_password, hot2_password
    Exec := RunWithStdin( A_AhkPath " """ A_ScriptDir "\Hotkeys_Reload_Intermediary.ahk"" *" ; "*" indicates that password should be read from stdin
                        , hot_password "`n" hot2_password )
    Sleep 500
    return true
}

#PgUp::         Volume_Up
#PgDn::         Volume_Down

#!VK4C::        SendRaw %hot_password% ;vk4C=l #!l
#!+VK4C::       SendRaw %hot2_password% ;vk4C=l #!+l
