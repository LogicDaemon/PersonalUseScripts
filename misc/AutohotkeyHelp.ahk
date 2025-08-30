#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData, LOCALAPPDATA
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
laPrograms := LocalAppData "\Programs"

autohotkeyHelp := (A_ComputerName == "ACERPH315-53-71")
                ? "https://www.autohotkey.com/docs/v1/"
                : FirstExisting( A_AhkDir "\AutoHotkey.chm"
                               , laPrograms "\AutoHotkey\AutoHotkey.chm"
                               , A_ProgramFiles "\AutoHotkey\AutoHotkey.chm" )
Run "%autohotkeyHelp%"

; https://www.libe.net/en-windows-build
