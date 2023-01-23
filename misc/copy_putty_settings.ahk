;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#SingleInstance force
#Warn
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

global DefaultSettingsKeyName := "Default%20Settings"
    , SessionsKey := "HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions"
    , puttySessions := {}
    , optionNameMaxLength := 0

If (A_Args.Count()) {
    CLICopyPuttySettings()
    ExitApp
}

PID := DllCall("GetCurrentProcessId")
GroupAdd OwnGUI, ahk_pid %PID%

BuildGUI()
Exit

#IfWinActive ahk_group OwnGUI
    Esc:: ExitApp
#If

SelectAllDestSessions:
    Gui +LastFound  ; Avoids the need to specify WinTitle below.
    PostMessage, 0x0185, 1, -1, ListBox3  ; Select all items. 0x0185 is LB_SETSEL.
return
DeselectAllDestSessions:
    Gui +LastFound  ; Avoids the need to specify WinTitle below.
    PostMessage, 0x0185, 0, -1, ListBox3  ; Deselect all items.
return

GUISourceSessionChange:
    RefreshGUIOptions()
return

ButtonLoadAllSettings:
    Gui Submit, NoHide
    LoadAllSessionsData()
return

ButtonCompareChanges:
    Gui Submit, NoHide
    GUISelectChangedOptions()
return

ButtonOK:
    Gui Submit, NoHide
    If (CopyViaGUI())
        TrayTip PuTTY settings copy, Settings copied successfully, 1
    return

GuiEscape:
GuiClose:
ButtonCancel:
ExitApp

BuildGUI() {
    local
    global optionNameMaxLength, puttySessions, DefaultSettingsKeyName
        , SessionsKey
        , GUISourceSession, GUIDestSessions, GUIOptionsChoice
    profileMaxLen := 0
        , puttySessionsString := ""
    Loop Reg, %SessionsKey%, K
    {
        keyName := A_LoopRegName
            , puttySessionsString .= keyName "`n"
            , profileMaxLen := Max(profileMaxLen, StrLen(keyName))
            , puttySessions[keyName] := ""
    }
    LoadSessionData(DefaultSettingsKeyName)
    puttySessionsString := SubStr(puttySessionsString, 1, -1) ; remove trailing separator
        , profileWidth := profileMaxLen * 6
        , optionWidth := optionNameMaxLength * 6 + 200
        , optionListTabWidth := optionNameMaxLength*3+1
    Gui +Delimiter`n
    Gui Add, Text, Section w%profileWidth%, Copy from profile
    Gui Add, ListBox, xs r30 w%profileWidth% Sort vGUISourceSession gGUISourceSessionChange, %puttySessionsString%
    
    Gui Add, Text, Section ym w%optionWidth%, Options to copy
    Gui Add, ListBox, xs r30 w%optionWidth% t%optionListTabWidth% 8 Sort vGUIOptionsChoice
    
    Gui Add, Text, Section ym w%profileWidth%, Copy to profiles
    Gui Add, ListBox, xs r30 w%profileWidth% 8 Sort vGUIDestSessions, %puttySessionsString%
    Gui Add, Button, Section gSelectAllDestSessions, +
    Gui Add, Button, ys gDeselectAllDestSessions, -
    Gui Add, Button, xm Section Default, OK
    Gui Add, Button, ys, Cancel
    Gui Add, Button, ys, &Load all settings
    Gui Add, Button, ys, &Compare changes
    
    GuiControl ChooseString, GUISourceSession, %DefaultSettingsKeyName%
    RefreshGUIOptions()
    Gui Show
}

LoadAllSessionsData() {
    local
    global puttySessions, SessionsKey
    
    Loop Reg, %SessionsKey%, K
    {
        If (!puttySessions[A_LoopRegName]) {
            GuiControl,, GUISourceSession, %A_LoopRegName%
            GuiControl,, GUIDestSessions, %A_LoopRegName%
        }
        puttySessions[A_LoopRegName] := LoadSessionData(A_LoopRegName)
    }
}

CopyViaGUI() {
    local
    global GUISourceSession, GUIOptionsChoice, GUIDestSessions, SessionsKey
    
    selectedOptions := []
    Loop Parse, GUIOptionsChoice, `n
        selectedOptions.Push(SubStr(A_LoopField, 1, InStr(A_LoopField, A_Tab, True)-1))
    destinationSessions := []
    Loop Parse, GUIDestSessions, `n
        destinationSessions.Push(A_LoopField)
    
    If (!selectedOptions.Count() || !destinationSessions.Count()) {
        MsgBox 0x30, PuTTY settings copy, Please select at least one option and one destination profile
        return False
    }

    sourceData := LoadSessionData(GUISourceSession, True)
    For _, targetSession in destinationSessions {
        For _, optionName in selectedOptions {
            sourceValue := sourceData[optionName]
            RegWrite % sourceValue[1], %SessionsKey%\%targetSession%, %optionName%, % sourceValue[2]
        }
    }
    return True
}

GUISelectChangedOptions(sessionName := "") {
    local
    global puttySessions, GUISourceSession, GUIOptionsChoice
    
    If (sessionName=="") {
        GuiControlGet sessionName,, GUISourceSession
        r := GUISelectChangedOptions(sessionName)
        If (r)
            return r
        skipSession := sessionName
        For sessionName, sessionData in puttySessions {
            If (sessionName==skipSession || puttySessions[sessionName] == "")
                continue
            GuiControl ChooseString, GUISourceSession, %sessionName%
            r := GUISelectChangedOptions(sessionName)
            If (r)
                return r
        }
        return False
    }
    oldData := puttySessions[sessionName]
    RefreshGUIOptions(sessionName, True)
    newData := puttySessions[sessionName]
        , selectOptions := ""
        , foundDiff := False
    For k, v in newData {
        If (!oldData.HasKey(k) || oldData[k] != v) {
            GuiControl ChooseString, GUIOptionsChoice, %k%
            foundDiff := True
        }
    }
    return foundDiff
}

RefreshGUIOptions(sessionName := "", force := False) {
    local
    global puttySessions
    If (sessionName=="")
        GuiControlGet sessionName,, GUISourceSession
    If (force || !puttySessions[sessionName])
        puttySessions[sessionName] := sessionData := LoadSessionData(sessionName)
    Else
        sessionData := puttySessions[sessionName]
    
    availableOptions := ""
    For k, v in sessionData
        availableOptions .= "`n" k "`t" v ; U+2502 Box Drawings Light Vertical
    
    GuiControl -Redraw, GUIOptionsChoice ; Disable redraw to speed up the process.
    GuiControl,, GUIOptionsChoice, %availableOptions%
    GuiControl +Redraw, GUIOptionsChoice
}

CLICopyPuttySettings() {
    local
    global A_Args, puttySessions, DefaultSettingsKeyName, SessionsKey
    
    optionNames := [], sourceSession := "", targetSessions := [], skipNext := False, modify := ""
    For i, arg in A_Args {
        If (skipNext) {
            skipNext := False
            continue
        }
        If arg in /source,/s
            skipNext := True, modify := "", sourceSession := A_Args[i+1]
        Else If arg in /options,/o
            modify := optionNames
        Else If arg in /destinations,/d
            modify := targetSessions
        Else If (modify)
            modify.Push(arg)
        Else {
            If arg in /help,/h,help,?,/?,-?
                MsgBox 0x40, Putty settings copy,
            (LTrim
                Usage:
                %A_ScriptName% [/source <session name>] [/options <option names>] [/destinations <session names>]
                
                /source <session name> - name of the session to copy settings from. Default: %DefaultSettingsKeyName%
                /options <option names> - list of options to copy. Default: None
                /destinations <session names> - list of sessions to copy settings to. Default: All sessions except the source one.
                
                Example:
                %A_ScriptName% /source Default`%20Settings /destinations MySession OtherSession /options TerminalType LinuxFunctionKeys
            )
            Else
                MsgBox 0x10, Putty settings copy, Unknown argument: %arg%
            ExitApp
        }
    }
    
    If (!sourceSession)
        sourceSession := DefaultSettingsKeyName
    If (!targetSessions)
        Loop Reg, %SessionsKey%, K
        {
            If (A_LoopRegName != sourceSession)
                targetSessions.Push(A_LoopRegName)
        }
    
    sourceData := LoadSessionData(sourceSession, True)
    For _, targetSession in targetSessions {
        For i, n in optionNames {
            If (sourceData[n]) {
                sv := sourceData[n]
                RegWrite % sv[1], %SessionsKey%\%targetSession%, %n%, % sv[2]
            }
        }
    }
}

LoadSessionData(sessionName, withTypes := False) {
    local
    global SessionsKey, optionNameMaxLength
    
    sessionOptions := {}
    Loop Reg, %SessionsKey%\%sessionName%
    {
        RegRead v
        optionNameMaxLength := Max(optionNameMaxLength, StrLen(A_LoopRegName))
            , sessionOptions[A_LoopRegName] := withTypes ? [A_LoopRegType, v] : v
    }
    return sessionOptions
}

Max(a, b) {
    local
    return a >= b ? a : b
}
