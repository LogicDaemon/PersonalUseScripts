;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#HotkeyModifierTimeout 0 ; it always times out (modifier keys are never pushed back down).

Process Priority,, High

ListLines Off
;SendMode InputThenPlay ; keyhook in installed either way because of some hotkeys
SetKeyDelay -1,-1
;SetBatchLines -1
SetFormat FloatFast, 0.3
SetFormat IntegerFast, Dec

SetTitleMatchMode RegEx
; For foobar2000 detection
DetectHiddenWindows On

;Defining some constants
WM_MENUSELECT:=0x011F

WindowSplitSize:=[1.2, 1.5, 1920/1024, 2, 2.5]
magnitudeSeq:=WindowSplitSize.MinIndex()

SplitPath A_AhkPath,, A_AhkDir
EnvGet ProgramFilesx86, ProgramFiles(x86)
If Not ProgramFilesx86
    ProgramFilesx86:=ProgramFiles
Envget LocalAppData, LOCALAPPDATA
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
laPrograms := LocalAppData "\Programs"

GreenshotExe := FirstExisting(A_ProgramFiles "\Greenshot\Greenshot.exe")

GroupAdd ExcludedFromAutoReplace, ahk_class ^SALFRAME
;GroupAdd ExcludedFromAutoReplace, ahk_class ^OperaWindowClass
GroupAdd ExcludedFromAutoReplace, ahk_class ^{E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
GroupAdd ExcludedFromAutoReplace, ahk_class ^TMsgWindow
GroupAdd ExcludedFromAutoReplace, ahk_class ^ConsoleWindowClass
;GroupAdd ExcludedFromAutoReplace, ahk_class ^Notepad2, ANSI
GroupAdd ExcludedFromAutoReplace, \.(bat|cmd) ahk_class ^Notepad2
;GroupAdd ExcludedFromAutoReplace, \.ahk ahk_class ^Notepad2
GroupAdd ExcludedFromAutoReplace, \.(bat|cmd)\b.* - Visual Studio Code ahk_exe \bCode\.exe\b

GroupAdd NonStandardLayoutSwitching, ahk_exe \iexplore\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \boutlook\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bOUTLOOK\.EXE\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bcmd\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bconhost\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bWINWORD\.EXE\b
GroupAdd NonStandardLayoutSwitching, ahk_class ^OpusApp

GroupAdd NoLayoutSwitching, ahk_exe CDViewer\.exe

calcexe := FirstExisting(laPrograms "\speedcrunch-0.12-win32\speedcrunch.exe"
                       , laPrograms "\calculators\preccalc-32bit\preccalc.exe"
                       , SystemRoot "\System32\calc.exe" )
For i, exe64suffix in (A_Is64bitOS ? ["64", ""] : [""]) {
    If (!totalcmdexe)
        totalcmdexe := FirstExisting(laPrograms "\Total Commander\TOTALCMD" exe64suffix ".EXE"
                                   , ProgramFiles . "\Total Commander\TOTALCMD" exe64suffix ".EXE"
                                   , ProgramFilesx86 . "\Total Commander\TOTALCMD" exe64suffix ".EXE")
    If (!procexpexe)
        procexpexe := FirstExisting(laPrograms "\SysUtils\SysInternals\procexp" exe64suffix ".exe"
                                  , laPrograms "\SysInternals\procexp" exe64suffix ".exe"
                                  , SystemDrive "\SysUtils\SysInternals\procexp" exe64suffix ".exe")
}
vscode := A_ScriptDir "\vscode.ahk"
notepad2exe := FirstExisting(laPrograms "\Total Commander\notepad2.exe"
                           , totalcmdexe "\..\notepad2.exe"
                           , ProgramFiles "\notepad2\notepad2.exe"
                           , ProgramFilesx86 "\notepad2\notepad2.exe"
                           , ProgramFilesx86 "\Notepad++\notepad++.exe"
                           , LocalAppData "\Programs\VSCode\Code.exe"
                           , SystemRoot "\System32\notepad.exe")

AU3_SpyExecArray := [FileExist(AU3_SpyExe := A_AhkDir "\AU3_Spy.exe") ? AU3_SpyExe : A_AhkDir "\WindowSpy.ahk",,""]

keepassahk := FirstExisting(A_ScriptDir "\KeePass_" A_UserName ".ahk", A_ScriptDir "\KeePass.ahk")

FileAppend Found executables:`ncalc: %calcexe%`nnotepad2: %notepad2exe%`ntc: %totalcmdexe%`nprocexp: %procexpexe%`nkeepassahk: %keepassahk%, *

layouts := GetLayoutList()

FillDelayedRunGroups()

;save a bit on memory if Windows 5 or newer - MilesAhead
DllCall("psapi.dll\EmptyWorkingSet", "Int", -1, "Int")

#include *i %A_ScriptDir%\Hotkeys_Custom.ahk
return

;---

; #If (!WinExist("ahk_exe Greenshot.exe"))
; ^PrintScreen::
;     If (!WinExist(ahk_exe SnippingTool.exe))
;         RunDelayed(A_WinDir "\system32\SnippingTool.exe",,"")
;     WinWait Snipping Tool ahk_class Microsoft-Windows-SnipperToolbar ahk_exe SnippingTool.exe
;     Sleep 100
;     WinActivate
;     SendEvent !{vk4E} ; vk4E=N, !N
;     ;ControlSend ToolbarWindow321, !{vk4E}
;     ;ControlClick ToolbarWindow321, x30 y16
; return
; #If (GreenshotExe && !WinExist("ahk_exe Greenshot.exe"))
; +PrintScreen::	RunDelayed(GreenshotExe,,"")

#IfWinNotActive ahk_group ExcludedFromAutoReplace
    #Hotstring * ? C Z
    ;* (asterisk): An ending character (e.g. space, period, or enter) is not required to trigger the hotstring
    ;? (question mark): The hotstring will be triggered even when it is inside another word
    ;B0 (B followed by a zero): Automatic backspacing is not done to erase the abbreviation you type
    ;C: Case sensitive
    ;C1: Do not conform to typed case. Hotstrings become case insensitive and non-conforming to the case of the characters you actually type
    ;Kn: Key-delay; k10 to have a 10ms delay and k-1 to have no delay
    ;O: Omit the ending character of auto-replace hotstrings when the replacement is produced
    ;R: Send the replacement text raw
    ;SI or SP or SE [v1.0.43+]: Sets the method by which auto-replace hotstrings send their keystrokes
    ;Z: This rarely-used option resets the hotstring recognizer after each triggering of the hotstring
    
    ;:?:"<::«
    ;::ЭБ::«
    ;:?:">::»
    ;::ЭЮ::»
    ::--- ::– `
    ::... ::… `
    ::>= ::≥ `
    ::<= ::≤ `
    ::<- ::← `
    ::-> ::→ `
    #Hotstring *0 ?0 C0 Z0
#IfWinActive

#+/::		    	Send ¿									;Win+Shift+/ #+/
#,::														;Win+< #<
    clipBak := ClipboardAll
    Clipboard=
    SendEvent +{Delete}
    ClipWait 0
    SendRaw «»
    SendEvent {Left}+{Insert}
    Sleep 50
    Clipboard := clipBak
    clipBak=
return
#^,::		        Send «									;Win+Ctrl+< #^<
#^.::		    	Send »									;Win+Ctrl+> #^>
#+,::		    	Send ≤									;Win+Shift+< #+<
#+.::		    	Send ≥									;Win+Shift+> #+>
#!,::			    Send ←									;Win+Alt+< #!<
#!.::		    	Send →									;Win+Alt+> #!>
#+VK44::	    	Send %A_YYYY%-%A_MM%-%A_DD%						;vk44=d	#+d
#+VK54::   	    	Send %A_Hour%%A_Min%							;vk54=t #+t
#NumpadSub::		Send –
#NumPadMult::		Send ×
#+NumPadMult::		Send ⋆
#!NumPadMult::		Send ☆
#!+NumPadMult::		Send ★
#!Insert::              SendRaw %Clipboard%

#^!+VK5A::              GoTo lReload								                            ;vk5a=z #^!+z
#^VK43::                Run "%A_AhkPath%" "%A_ScriptDir%\ClipboardMonitor.ahk",, Min	;vk43=c #^c

#^F1::                  Run % "*RunAs " comspec " /K CD /D ""%TEMP%"""
#Enter::                GoTo lMaximizeWindow
#+Enter::               GoTo lMaximizeOnNextMonitor

#^!NumPad0::	        WinSet AlwaysOnTop, Toggle, A
#^Delete::		WinKill A
#+Down::		PostMessage 0x112, 0xF020,,, A ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE
;https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms646360%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
#!Numpad1::
#!Numpad2::
#!Numpad3::
#!Numpad4::
#!Numpad6::
#!Numpad7::
#!Numpad8::
#!Numpad9::
    If ( A_TimeSincePriorHotkey < 1000) {
	If (A_PriorHotkey == A_ThisHotkey)
	    magnitudeSeq += magnitudeSeq < WindowSplitSize.MaxIndex()
    } else {
	magnitudeSeq := WindowSplitSize.MinIndex()
    }
    Tooltip % "Magnitude #" . magnitudeSeq . " = " . WindowSplitSize[magnitudeSeq]
    SetTimer RemoveToolTip, 1000
    MoveToCornerNum(SubStr(A_ThisLabel,0), WindowSplitSize[magnitudeSeq])
return

FillDelayedRunGroups() {
    ;Error:  Parameter #2 must match an existing #If expression.
    ;--->	087: Hotkey,If,("AlternateHotkeys==" altMode)
    ;vk5a=z #z
    #If AlternateHotkeys==0x5A
    #If
    local altKey, HotkeysRunDelayed, altMode, altFunc, key, args, hotkeyFunc, OutExtension
    ; {key: [File, Arguments, Directory, Operation, Show], ...} ; Show is as in ShellRun or -1 to run as ahk script (w/o ShellRun)
        , RunDelayedGroups :=   { "":       { "#!VK43":	 [calcexe,, ""]								;#!c
                                            , "SC132":   [A_ScriptDir "\Vivaldi.ahk"]						;SC132=Homepage
                                            , "#VK57":   [A_ScriptDir "\Vivaldi.ahk"]						;vk57=w #w
                                            , "#+VK57":	 [A_ScriptDir "\Chromium.ahk"]						;vk57=w #+w
                                            , "+SC132":	 [A_ScriptDir "\Chromium.ahk"]						;SC132=Homepage +Homepage
                                            , "^!+Esc":  [procexpexe]								;^!+Esc
                                            , "^SC132":  [A_ScriptDir "\opera.cmd",,,,7]                           		;^Homepage
                                            , "#SC132":  [A_ScriptDir "\ie.cmd",,,,7]						;#Homepage
                                            , "#^!VK57": [laPrograms "\Tor Browser\Browser\firefox.exe",,,,7]			;#^!w
                                            , "^!SC132": [laPrograms "\Tor Browser\Browser\firefox.exe",,,,7]			;^!Homepage
                                            , "Browser_Favorites": [A_ScriptDir "\Skype.cmd",,,,7]				;
                                            , "Launch_Mail": [A_ScriptDir "\email_button.ahk",,""]				;
                                            , "#F1":     [comspec, " /K ""CD /D """ A_ScriptDir """ & PUSHD ""%TEMP%"" & ECHO POPD to go to " A_ScriptDir """"]		;/U https://twitter.com/LogicDaemon/status/936259452617060354
                                            , "#VK45":   [totalcmdexe,,""]	                                                ;vk45=e #e
                                            , "#+VK45":  [totalcmdexe,,,,-1]							;vk45=e #+e
                                            , "#!VK45":  ["shell:MyComputerFolder"]						;vk45=e #!e
                                            , "#^VK45":  [A_ScriptDir "\RemoveDrive.ahk"]					;vk45=e #^e
                                            , "#^+VK45": [eject_all.cmd]							;vk45=e #^+e
                                            , "#!VK4B":  [keepassahk,,""]							;vk4B=k #!k
                                            , "#!+VK4B": [laPrograms "\WinAuth\WinAuth.exe",,""]				;vk4C=l, #!+k
                                            , "#VK50":   [notepad2exe]							        ;vk50=p #p
                                            , "#+VK50":  [notepad2exe,"/c /b"]						        ;vk50=p	#+p
                                            , "#!VK50":  [A_ScriptDir "\QuickText.ahk"]				                ;vk50=p #!p
                                            , "#VK54":   [A_ScriptDir "\tombo.cmd",,,,7]				        ;vk54=t #t
                                            , "#VK56":	 [vscode]						    		;vk56=v #v
                                            , "#!VK57":  [A_ScriptDir "\palemoon.cmd",,,,7]					;vk57=w #!w
                                            , "#!VK53":	 [A_ScriptDir "\EmailSelection.ahk",, ""] }				;vk53=s #!s
                                , "#VK5A":  { "#VK44":	 [A_ScriptDir "\GoogleDrive.ahk"]				        ;vk5a=z #z vk44=d #d
                                            , "#+VK44":	 [A_ScriptDir "\Dropbox.ahk"]					        ;vk44=d #+d
                                            , "^VK45":	 [notepad2exe, """" A_ScriptFullPath """"]			        ;vk45=e ^e
                                            , "^+VK45":	 [notepad2exe, """" A_ScriptDir "\Hotkeys_Custom.ahk"""]	        ;vk45=e ^+e
                                            , "#VK57":	 AU3_SpyExecArray			          	 	 	;vk57=w #w
                                            , "#VK52":	 [A_ScriptDir "\LiceCapResize.ahk",,""]	        			;vk52=r #r
                                            , "+F1": 	 [A_AhkDir "\AutoHotkey.chm",,""] } }

    For altKey, HotkeysRunDelayed in RunDelayedGroups {
        If (altKey) {
            altMode := SubStr(altKey,-1) ; two last characters for label name are VK code, used as AlternateHotkeys code
            altFunc := Func("PrepareAltMode").Bind(altMode)
            Hotkey %altKey%, %altFunc%
            Hotkey If, AlternateHotkeys==0x%altMode%
        }
        For key,args in HotkeysRunDelayed {
            If (FileExist(args[1])) {
                SplitPath % args[1], , , OutExtension
                If (OutExtension = "ahk") {
                    args[2] := """" args[1] """ " args[2]
                    args[1] := A_AhkPath
                }
                hotkeyFunc := Func("RunDelayed").Bind(args*)
                HotKey %key%, %hotkeyFunc%
            } Else {
                FileAppend % "Not found: " args[1], *
            }
        }
        If (altKey)
            HotKey If
    }
}

RemoveToolTip:
    SetTimer RemoveToolTip, Off
    ToolTip
return

~LShift Up:: SwtichLang(layouts[1]) ; LOCALE_EN := 0x4090409
~RShift Up:: SwtichLang(layouts[2]) ; LOCALE_RU := 0x4190419
SwtichLang(newLocale) {
    Thread Priority, 1 ; No re-entrance
    If (A_ThisHotkey == "~" A_PriorKey " Up" && !WinActive("ahk_group NoLayoutSwitching")) {
	If ( InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinExist("A"), "UInt", 0), "UInt") ) {
            If (InputLocaleID != newLocale) { ; if language is not english XOR requested non-english
                ; WinGet ProcessName, ProcessName, A
                ; WinGetClass WinClass, A
                ; WinGet ProcessPath, ProcessPath
                ; ToolTip
                ; ToolTip %WinClass% %ProcessPath%
                If (WinActive("ahk_group NonStandardLayoutSwitching")) {
                    ToolTip Переключение раскладки через Win+Space
                    SendEvent #{Space}
                    Sleep 250
                    ToolTip
                } Else {
                    ControlGetFocus,ctl
                    PostMessage 0x50,3,%newLocale%,%ctl%,A ;WM_INPUTLANGCHANGEREQUEST - change locale, documentation https://msdn.microsoft.com/en-us/library/windows/desktop/ms632630.aspx
                    ; wParam
                    ; INPUTLANGCHANGE_BACKWARD 0x0004 A hot key was used to choose the previous input locale in the installed list of input locales. This flag cannot be used with the INPUTLANGCHANGE_FORWARD flag.
                    ; INPUTLANGCHANGE_FORWARD 0x0002 A hot key was used to choose the next input locale in the installed list of input locales. This flag cannot be used with the INPUTLANGCHANGE_BACKWARD flag.
                    ; INPUTLANGCHANGE_SYSCHARSET 0x0001 The new input locale's keyboard layout can be used with the system character set.
                }		
	    }
	}
    }
}

GetLayoutList() { ; List of system loaded layouts, from Lyt.ahk / https://autohotkey.com/boards/viewtopic.php?p=132600#p132600
    aLayouts := []
    size := DllCall("GetKeyboardLayoutList", "UInt", 0, "Ptr", 0)
    VarSetCapacity(list, A_PtrSize*size)
    size := DllCall("GetKeyboardLayoutList", Int, size, Str, list)
    Loop % size {
	aLayouts[A_Index] := NumGet(list, A_PtrSize*(A_Index - 1))
	;aLayouts[A_Index].hkl := NumGet(List, A_PtrSize*(A_Index - 1))
	;aLayouts[A_Index].LocName := this.GetLocaleName(, aLayouts[A_Index].hkl)
	;aLayouts[A_Index].LocFullName := this.GetLocaleName(, aLayouts[A_Index].hkl, true)
	;aLayouts[A_Index].LayoutName := this.GetLayoutName(, aLayouts[A_Index].hkl)
	;aLayouts[A_Index].KLID := this.GetKLIDfromHKL(aLayouts[A_Index].hkl)
    }
    Return aLayouts
}

MoveToCornerNum(Corner, WindowSplitSize=2) {
    If Corner In 1,2,3
        VerticalSize:=WindowSplitSize
    If Corner In 7,8,9
        VerticalSize:=-WindowSplitSize
    If Corner In 1,4,7
        HorizontalSize:=-WindowSplitSize
    If Corner In 3,6,9
        HorizontalSize:=WindowSplitSize
    MoveToCorner(HorizontalSize,VerticalSize)
}

MoveToCorner(HorizSplit, VertSplit, MonNum := -1) {
    ; HorizSplit, VertSplit are as foolowing
    ;  0 = don't touch
    ;  1 = fullscreen,  2 = right/bottom half of screen, 3 = right/bottom third of screen, etc.
    ; -1 = fullscreen, -2 = left/top half of screen,    -3 = left/top third of screen, etc.
    ;  MonNum is monitor # as in SysGet, var, Monitor, #
    ; -1 for monitor of current window, "" for primary monitor
    
    IfWinNotExist A
	return
    
    ;Now get window position
    WinGetPos newX, newY, newW, newH
    WinCentralPointX := newX + newW/2
    WinCentralPointY := newY + newH/2

    If (MonNum == -1) { ; If current window' monitor should be used, find it
        Loop {
            SysGet MonDim, Monitor, %A_Index%
            If ( MonDimLeft < WinCentralPointX && MonDimRight > WinCentralPointX && MonDimTop < WinCentralPointY && MonDimBottom > WinCentralPointY ) {
                MonNum := A_Index
                break
            }
            ;~ MsgBox %MonDimLeft% < %WinCentralPointX% && %MonDimRight% > %WinCentralPointX% && %MonDimTop% < %WinCentralPointY% && %MonDimBottom% > %WinCentralPointY%
        } until !(MonDimLeft || MonDimRight || MonDimTop || MonDimBottom)
    }
    If (MonNum == -1) { ; If monitor number isn't found with previous loop
        MonNum = ; Primary monitor will be used instead
        TrayTip Cannot find current monitor,WinCentralPointX = %WinCentralPointX%`nWinCentralPointY = %WinCentralPointY%,,0x22
    }
    
    SysGet MonWA, MonitorWorkArea, %MonNum%
    borderSize := 8
    If (HorizSplit) {
	newW := Abs((MonWARight - MonWALeft) / HorizSplit) + borderSize + borderSize
	If (HorizSplit<0)
	    newX := MonWALeft - borderSize
	else
	    newX := MonWARight - newW + borderSize
    }
    If (VertSplit) {
	newH := Abs((MonWABottom - MonWATop) / VertSplit) + borderSize + borderSize
	If (VertSplit < 0)
	    newY := MonWATop - borderSize
	else
	    NewY := MonWABottom - NewH + borderSize
    }
	
    WinMove,,, newX, newY, , 
    WinMove,,, , , newW, newH
;    ToolTip newX: %newX% newY: %newY%`nnewW: %newW% newH: %newH%
}

PrepareAltMode(ByRef altMode) {
    global AlternateHotkeys
    AlternateHotkeys := "0x" altMode
    AlternateHotkeys+=0 ; +0 to ensure it's converted to number. Not necessary though.
    Tooltip %A_ThisHotkey% (%AlternateHotkeys%) ; / %A_ThisLabel%
    SetTimer AlternateHotkeysOff, -1000
}

AlternateHotkeysOff() {
    global AlternateHotkeys
    AlternateHotkeys:=""
    Tooltip
}

lReload:
    ToolTip
    ToolTip Reloading
    AlternateHotkeys:=0
    Reload
    Sleep 300 ; if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox 4,, The script could not be reloaded. Would you like to open it for editing?
    IfMsgBox, Yes
        RunDelayed(notepad2exe " """ A_ScriptFullPath """")
return
    
lMaximizeOnNextMonitor:
    IfWinNotExist A
	return
    KeyWait LWin, L
    KeyWait RWin, L
    ;~ Send {LWin Up}{RWin Up}
    WinGetPos X, Y, W, H
    WinCentralPointX := X + W/2
    WinCentralPointY := Y + H/2
    
;	ToDo: find current monitor, select next (get it from resizing func.)
    
    SysGet Monitor1Dimensions, Monitor, 1
    SysGet Monitor2Dimensions, Monitor, 2
    If ( ( WinCentralPointX > Monitor1DimensionsLeft ) && ( WinCentralPointX < Monitor2DimensionsLeft ) )
	X := X - Monitor1DimensionsLeft + Monitor2DimensionsLeft
    else
	X := X - Monitor2DimensionsLeft + Monitor1DimensionsLeft
    
    PostMessage, 0x112, 0xF120,,, A  ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
    Sleep 0
    WinMove %X%, %Y%
    Sleep 0

lMaximizeWindow:
    WinGet WinMinMaxState, MinMax, A
    If WinMinMaxState
	PostMessage, 0x112, 0xF120,,, A  ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
    Else
	PostMessage 0x112, 0xF030,,, A ; 0x112 = WM_SYSCOMMAND, 0xF030 = SC_MAXIMIZE
;    TODO: restore window original position
    return

RunDelayed(ByRef params*) { ; File [, Arguments, Directory, Operation, Show]; Show is as in ShellRun or -1 to run as ahk script (w/o ShellRun)
    static runQueue := Object()
    
    If (IsObject(params) && nparams := params.Length()) {
        AlternateHotkeysOff()
        RunQueue.Push((nparams==1) ? params[1] : params)
        SetTimer %A_ThisFunc%, 1
        ToolTip % "Added " ((nparams==1) ? params[1] : params) " to launch queue"
        SetTimer RemoveToolTip, 1000
        return
    } Else {
        If (cmd := runQueue.Pop()) {
            If (IsObject(cmd)) { ; not only executable name
                If (cmd[5] == -1)
                    RunAndActivate(cmd*)
                Else
                    nprivRun(cmd*)
            } Else { ; only executable name, with no parameters or workdir
                If (FileExist(cmd)) {
                    SplitPath cmd,exename,wd,ext
                    If (ext = "exe" && (UniqueID := WinExist("ahk_exe " exename)) && !WinActive("ahk_id " UniqueID)) {
                        WinGet state, MinMax, ahk_exe %exename%
                        If (state == -1)
                            WinRestore ahk_exe %exename%
                        WinActivate
                        ToolTip % "Activated " cmd
                        SetTimer RemoveToolTip, 1000
                    } Else {
                        RunAndActivate(  ext = "ahk" ? """" A_AhkPath """ """ cmd """"
                                       : ext = "cmd" ? """" comspec """ /C """ cmd """"
                                       : """" cmd """")
                    }
                } Else {
                    RunAndActivate(cmd)
                }
            }
        } Else {
            SetTimer ,,Off
        }
    }
}

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

RunAndActivate(ByRef tgt, ByRef wd:="", ByRef options:="") {
    If (!wd)
	wd := A_Temp
    Run %tgt%, %wd%, %options%, r_PID
    WinWait ahk_PID %r_PID%,,3
    If (!ErrorLevel)
	WinActivate
    Tooltip Started and activated %tgt%
    SetTimer RemoveToolTip, 1000
}

PasteViaClip(t) {
    If (!clipBak)
	clipBak:=ClipboardAll
    Clipboard:=t
    Sleep 100
    Send +{Ins}
    Sleep 300
    Clipboard:=clipBak
    clipBak=
}

#include <ShellRun by Lexikos>
nprivRun(args*) { ; args for ShellRun: File [, Arguments, Directory, Operation, Show]
    ;Show = args[5]:
    ;0 Open the application with a hidden window.
    ;1 Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
    ;2 Open the application with a minimized window.
    ;3 Open the application with a maximized window.
    ;4 Open the application with its window at its most recent size and position. The active window remains active.
    ;5 Open the application with its window at its current size and position.
    ;7 Open the application with a minimized window. The active window remains active.
    ;10 Open the application with its window in the default state specified by the application.

    ;    XP
    ;	RunString:="""" . args[1] . """ " . args[2]
    ;	Dir := args[3]
    ;	Verb := "*" . args[4]
    ;	If (args[5]!="") {
    ;	    ShowModes := ["Hide","", "Min", "Max", "", "", "Min", ""]
    ;	    ShowMode := ShowModes[args[5]+1]
    ;	}
    ;	Run %Verb% %RunString%, %Dir%, %ShowMode%
    If (args[5]=="") {
	args[5]:=""
    }
    If (args[3]=="") {
	SplitPath % args[3],, dir
	args[3] := dir
    }
    skipPaths := {"autohotkey.exe": "", "cmd.exe": ""}
    For i, path in args {
        path := Trim(path, """ ")
        SplitPath path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        If (!skipPaths.HasKey(Format("{:L}", OutFileName))) {
            ToolTip % "Starting " OutFileName " via shell and activating the window"
            SetTimer RemoveToolTip, 1000
            break
        }
    }
    retval := ShellRun(args*)

    If (args[5] >= 1 && args[5] <= 3) {
	exepath:=args[1]
	WinWait ahk_exe %exepath%, , 3
	Sleep 50
	IfWinNotActive 
	{
	    WinSet AlwaysOnTop, Toggle
	    Sleep 5
	    WinSet AlwaysOnTop, Toggle
	    WinActivate
	}
    }
}

StrJoin(separator := "", strings*) {
    o := ""
    For i, str in strings
        o .= str . separator
    return StrLen(separator) ? SubStr(o, 1, -StrLen(separator)) : o
}

GetOSVersion() {
    ; From http://www.autohotkey.com/board/topic/54639-getosversion/
    Return ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF) "." (r >> 8)
}

FirstExisting(paths*) {
    For i, path in paths
        If (FileExist(path))
            return path
    return ""
}
