;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance ignore

clipAcc := ""
, ClipboardCaptureOn := 1
, clipboardsCaptured := 0
, ClipboardTypes := {0: "empty", 1: "text", 2: "non-text"}
, clipText := {0: "", 1: ""}

Exit

#^VK56::	; ;vk56=v #v
#+Ins::
    ClipboardCaptureOn = 0
    Clipboard := clipAcc
    Send % SubStr(A_ThisHotkey, 2, 1) "{" SubStr(A_ThisHotkey, 3) "}"
    ToolTip Pasted`, Capture buffer cleared
    Sleep 1500
    ToolTip
ExitApp

OnClipboardChange:
    If ( ClipboardCaptureOn and A_EventInfo == 1 ) {
        clipNewIdx := clipboardsCaptured & 0x1, clipOldIdx := clipNewIdx ^ 0x1 ; & = and, ^ = xor
        clipText[clipNewIdx] := IsFunc("CutTrelloURLs") ? Func("CutTrelloURLs").Call(Clipboard) : Clipboard
        If (clipText[clipOldIdx] != clipText[clipNewIdx]) {
            clipAcc .= (clipboardsCaptured++ ? "`n" : "") . clipText[clipNewIdx]
            ToolTip % "Clipboard changed. Type:" . ClipboardTypes[A_EventInfo] ", Captures: " . clipboardsCaptured
                    . (A_EventInfo==1 ? "`nContents:`n " . clipText[clipNewIdx] : "")
        }
    } Else {
        ToolTip % "Clipboard changed. Type:" . ClipboardTypes[A_EventInfo] ", Captures: " . clipboardsCaptured
    }
    SetTimer RemovePopup, -750
return

RemovePopup:
    ToolTip
return

#include *i <CutTrelloURLs>