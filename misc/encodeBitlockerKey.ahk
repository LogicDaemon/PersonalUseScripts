;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
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
