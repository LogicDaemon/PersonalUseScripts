#NoEnv
#SingleInstance force
#InstallKeybdHook
#MaxHotkeysPerInterval 500

;This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.

Global IdleDelay, LargeDisplay

IdleDelay:=3000

LargeDisplay:=1
; 0 = Tooltip near mouse pointer
; 1 = Big pane at screen bottom

;TrayTip %A_ScriptName%, Чтобы выйти`, нажмите правую клавишу Windows
TrayTip %A_ScriptName%, To Exit`, press the Right Windows logo key.

InputHook := InputHook("BCL1qMV*", "", "")
InputHook.KeyOpt("{All}", "INV")
InputHook.OnKeyDown := Func("OnKeyDown")
InputHook.OnKeyUp := Func("OnKeyUp")
InputHook.OnEnd := Func("RegisterKey")
Loop {
    InputHook.Start()
    InputHook.Wait()
}

return

RWin::
    ExitApp

~*LButton::
~*RButton::
~*MButton::
~*XButton1::
~*XButton2::
    MouseTooltip(SubStr(A_ThisHotkey, 3), 1)
    return

~*LButton Up::
~*RButton Up::
~*MButton Up::
~*XButton1 Up::
~*XButton2 Up::
    MouseTooltip(SubStr(A_ThisHotkey, 3, -3), 0)
    return

~*WheelDown::
~*WheelUp::
~*WheelLeft::
~*WheelRight::
    MouseTooltip(SubStr(A_ThisHotkey, 3), 1)
    MouseTooltip(SubStr(A_ThisHotkey, 3), 0)
    return

MouseTooltip(mbuttons, state){
    RegisterKey(mbuttons, state)
}

TooltipOff:
    If LargeDisplay
        Gui Hide
    Else
        Tooltip
    lastStatesText := {}
    return

OnKeyDown(inputHook, VK, SC) {
    RegisterKey(inputHook, 1, VK, SC)
}

OnKeyUp(inputHook, VK, SC) {
    RegisterKey(inputHook, 0, VK, SC)
}

RegisterKey(inputHook, kstate := 1, VK := 0, SC := 0) {
    local
    global IdleDelay, lastStatesText, inputString
    static keyStates := {}, prevKey, lastPressed, prevState, repeated := 0
         , KeyMappingToName := { (Chr(27)): "Escape"
                               , (Chr(32)): "Space"
                               , (Chr(10)): "Enter" }
         , SkipRepeat := { "LShift": ""
                         , "RShift": ""
                         , "LControl": ""
                         , "RControl": ""
                         , "LAlt": ""
                         , "RAlt": ""
                         , "LWin": ""
                         , "RWin": "" }
         , StringEndKeys := { "{Enter}": ""
                            , "{Escape}": ""
                            , "{Tab}": ""
                            , "{Up}": ""
                            , "{Down}": ""
                            , "{PgUp}": ""
                            , "{PgDn}": "" }
    
    If (VK || SC) {
        singleKey := GetKeyName(Format("vk{:02x}sc{:02x}", VK, SC))
    } Else If (!IsObject(inputHook)) {
        singleKey := inputHook
    }
    textKey := StrLen(singleKey) == 1 ? singleKey : "{" singleKey "}"
    keyStatesText := ""
    For key, state in keyStates
        If (state && key != singleKey)
            keyStatesText .= key "+"
    keyStates[singleKey] := kstate
    If (kstate && lastPressed == textKey && keyStatesText == lastStatesText) {
        If (!SkipRepeat.HasKey(singleKey))
            repeated++
    } Else {
        If (kstate) {
            If (repeated) {
                inputString .= (repeated > 4 || StrLen(lastPressed) > 1) ? "×" . repeated+1 : StrRepeat(lastPressed, repeated)
                , repeated := 0
            }
            If (keyStatesText != lastStatesText || StringEndKeys.HasKey(lastPressed))
                inputString := textKey, lastStatesText := keyStatesText
            Else If (StrLen(inputString) < 15)
                inputString .= textKey
            Else
                inputString := "…" SubStr(inputString, -15) textKey
            lastPressed := textKey
        }
    }
    ShowKeys((lstate ? keyStatesText : lastStatesText) . inputString . (repeated ? ("×" . repeated+1) : (kstate ? "↓" : "↑")))
    prevKey := singleKey, prevState := kstate
    
    SetTimer TooltipOff, % -IdleDelay
}

ShowKeys(text) {
    global GUIx, GUIy, GUIw, GUIh
         , blkOsdCtrlName, blkOsdCtrlName2
         , MonitorLeft, MonitorRight, MonitorBottom, MonitorTop
    
    If (LargeDisplay) {
        CoordMode Mouse, Screen
        MouseGetPos MouseX, MouseY

        InitLargeDisplay(MouseX, MouseY)
        
        If ((!GUIy) || (MouseX >= MonitorLeft && MouseX <= MonitorRight && MouseY >= GUIy && MouseY <= (GUIy+GUIh)) ) {
            If (MouseY < (MonitorTop + (MonitorBottom - MonitorTop) / 2) )
                GUIy := MonitorBottom - (MonitorBottom - MonitorTop) * 0.2
            Else
                GUIy := MonitorTop + (MonitorBottom - MonitorTop) * 0.2
        }
        
        GuiControl Text, blkOsdCtrlName, %text%
        GuiControl Text, blkOsdCtrlName2, %text%

        Gui, Show, x%GUIx% y%GUIy% NoActivate
    } Else {
        Tooltip % text
    }
}

InitLargeDisplay(MouseX, MouseY) {
    global GUIx, GUIy, GUIw, GUIh
         , blkOsdCtrlName, blkOsdCtrlName2
         , Monitor, MonitorLeft, MonitorRight, MonitorBottom, MonitorTop
    static guiInitialized := False
    ;Initializing GUI / reinitializing after changing monitor
    ;modded func originated from http://www.autohotkey.com/board/topic/8190-osd-function/

    If ( (   MouseX < MonitorLeft
          || MouseX > MonitorRight
          || MouseY < MonitorTop
          || MouseY > MonitorBottom)
        || !guiInitialized) { ; mouse is outside of last screen GUI was positioned at
        ;80 SM_CMONITORS: Number of display monitors on the desktop (not including "non-display pseudo-monitors"). 
        SysGet monCount, 80
        Loop % monCount
        {
            SysGet Monitor, Monitor, %A_Index%
            If (MouseX >= MonitorLeft && MouseX <= MonitorRight && MouseY >= MonitorTop && MouseY <= MonitorBottom) {
                found := true
                break
            }
        }

        If (!found) ; mouse cursor not found on any screen, fallback to default monitor
            SysGet Monitor, Monitor
        
        GUIx := MonitorLeft
        , GUIw := MonitorRight - MonitorLeft
        , GUIh := (MonitorBottom - MonitorTop) * GUIw * 0.00003
        If (GUIh > ((MonitorBottom - MonitorTop) * 0.3))
            GUIh := (MonitorBottom - MonitorTop) * 0.3
        
        opacity:="230"
        , fname:="Tahoma"
        , fsize:=GUIh * 0.65 ; really, pixel = 0.75 point, but with 0.75 lowercase letter with lower part (like "g") will get cut
        , fcolor:="cccccc"
        , bcolor:="222222"
        , fformat:="600"
        
        If (guiInitialized)
            Gui Destroy
        Gui +LastFound +AlwaysOnTop +ToolWindow -Caption
        Gui Margin, 0, 0 ;pixels of space to leave at the left/right and top/bottom sides of the window when auto-positioning.
        Gui Color, ffffff ;changes background color
        Gui Font, s%fsize% w%fformat%, %fname%

        ; 0x80 = SS_NOPREFIX -> Ampersand (&) is shown instead of underline one letter for Alt+letter navigation
        Gui Add, Text, c%bcolor% Center +0x80 w%GUIw% h%GUIh% BackgroundTrans VblkOsdCtrlName, tesT test test
        Gui Add, Text, c%fcolor% Center +0x80 w%GUIw% h%GUIh% BackgroundTrans VblkOsdCtrlName2 xp-3 yp-3 , tesT test test
        
        WinSet ExStyle, +0x20 ; WS_EX_TRANSPARENT -> mouse klickthrough
        WinSet TransColor, ffffff %opacity%

        guiInitialized := True
    }
}

StrRepeat(str, cnt) {
    If (cnt<1)
        return ""
    o := str
    Loop % cnt-1
        o .= str
    return o
}
