#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData, LOCALAPPDATA
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
laPrograms := LocalAppData "\Programs"

autohotkeyHelp := FirstExisting( A_AhkDir "\AutoHotkey.chm"
                               , laPrograms "\AutoHotkey\AutoHotkey.chm"
                               , A_ProgramFiles "\AutoHotkey\AutoHotkey.chm" )
If (!autohotkeyHelp)
    autohotkeyHelp = https://www.autohotkey.com/docs/v1/
Run "%autohotkeyHelp%"

; https://www.libe.net/en-windows-build
