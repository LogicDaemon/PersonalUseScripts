;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

LessAnnoyingAttentionDrawer(ByRef SubText, ByRef MainText, ByRef WinTitle, ByRef сallbackWaitLoop := "") {
    Progress zh0 M, %SubText%, %MainText%, %WinTitle%
    lastHotkeyTime := A_TickCount
    Loop
	Sleep 250
    Until A_TimeIdlePhysical > 500 ; ожидание простоя
    Loop
	Sleep 200
    Until A_TimeIdlePhysical < 200 ; ожидание любого действия пользователя

    While (IsFunc(сallbackWaitLoop) ? Func(сallbackWaitLoop).Call() : (A_TickCount - lastHotkeyTime) < 1000) ; в течение 1 с после нажатия клавиши, можно нажать ещё раз
	Sleep 200
    Progress Off
}

GuiEscape:
GuiClose:
    Sleep 200
    ExitApp
