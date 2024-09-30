;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

InputBox recoveryKey, Recovery Key, should be in form dddddd-dddddd-dddddd-dddddd-dddddd-dddddd-dddddd-dddddd

encoded := ""
Loop Parse, recoveryKey, -
{
    ; Ensure numeric
    If (!RegExMatch(A_LoopField, "^\d{6}$")) {
        MsgBox 0x10, %A_ScriptName%, Invalid key part: %A_LoopField%
        ExitApp 1
    }
    encoded .= NumToChars(A_LoopField + 0, 999999)
}

Gui Add, Edit, w500 h100 vOutput, % encoded
Gui Show
return

GuiClose:
GuiEscape:
ExitApp
