;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

default_browser_script_path = %A_ScriptDir%\default_browser@%A_ComputerName%.ahk
If (FileExist(default_browser_script_path)) {
    Run *Edit "%default_browser_script_path%"
    ExitApp
}

Gui Add, Button, Default, Vivaldi
Gui Add, Button, xs, Firefox
Gui Add, Button, xs, custom
Gui Show
Exit

GuiClose:
GuiEscape:
    ExitApp

ButtonVivaldi:
ButtonFirefox:
    browser_name := SubStr(A_ThisLabel, StrLen("Button")+1)
    FileAppend #include `%A_ScriptDir`%\%browser_name%.ahk`n, %default_browser_script_path%
    ExitApp
Buttoncustom:
FileSelectFile default_browser, 35, %A_ScriptDir%, Select a default browser for %A_ComputerName%, Executables (*.exe; *.ahk; *.cmd; *.bat)
SplitPath default_browser, name, dir, ext
If (dir = A_ScriptDir && ext == "ahk") {
    FileAppend #include `%A_ScriptDir`%\%name%`n, %default_browser_script_path%
    ExitApp
}
FileAppend,
(
#NoEnv
#NoTrayIcon
FileEncoding UTF-8

cl_args := ParseScriptCommandLine()
If (WinActivateOrExec("%default_browser%")) {
    ToolTip Activated %executable_name%
} Else {
    Tooltip Started %cl_args%
}
Sleep 1000
Tooltip
ExitApp

#include `%A_ScriptDir`%\WinActivateOrExec.ahk
), %default_browser_script_path%
ExitApp
