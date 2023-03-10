;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

;SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
SplitPath A_AhkPath,,ahkDir

For i, notepad2exe in   [ "C:\Program Files\Notepad2\Notepad2.exe"
                        , "C:\Program Files\Notepad2-mod\Notepad2.exe"
                        , "C:\Program Files (x86)\Notepad2\Notepad2.exe"
                        , "C:\Program Files (x86)\Notepad2-mod\Notepad2.exe"
                        , "%LOCALAPPDATA%\Programs\Notepad2\Notepad2.exe" 
                        , "%LOCALAPPDATA%\Programs\Total Commander\Notepad2.exe"
                        , "" ]
    If (!notepad2exe || FileExist(ExpandEnvVars(notepad2exe)))
        break

classesRoot := A_IsAdmin ? "HKEY_CLASSES_ROOT" : "HKEY_CURRENT_USER\Software\Classes"

If (!A_IsAdmin) {
    ; for HKCR, keep the paths plain and full
    ahkDir := SubstPathsWithEnvvars(ahkDir)
    ahkPath := SubstPathsWithEnvvars(ahkPath)
}

RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript,,AutoHotkey Script
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\DefaultIcon,,%A_AhkPath%`,1
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell,,Open
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Compile,,Compile Script
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Compile\Command,,"%ahkDir%\Compiler\Ahk2Exe.exe" /in "`%l" `%*
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Compile-Gui,,Compile Script (GUI)...
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Compile-Gui\Command,,"%ahkDir%\Compiler\Ahk2Exe.exe" /gui /in "`%l" `%*
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Edit,,Edit Script
If (notepad2exe) {
    RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Edit\Command,,"%notepad2exe%" "`%l"
} Else {
    RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Edit\Command,,notepad.exe `%1
}

RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Open,,Run Script
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\Open\Command,,"%A_AhkPath%" /CP65001 "`%1" `%*
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\RunAs, HasLUAShield,
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\Shell\RunAs\Command,,"%A_AhkPath%" "`%1" `%*
RegWrite REG_SZ, %classesRoot%\AutoHotkeyScript\ShellEx\DropHandler,,{86C86720-42A0-1069-A2E8-08002B30309D}

RegWrite REG_SZ, %classesRoot%\.ahk,, AutoHotkeyScript
RegWrite REG_SZ, %classesRoot%\.ahk\ShellNew, FileName, Template.ahk

SubstPathsWithEnvvars(ByRef path) {
    For i, var in   [ "LOCALAPPDATA"
                    , "APPDATA"
                    , "USERPROFILE"
                    , "CommonProgramFiles(x86)"
                    , "CommonProgramFiles"
                    , "ProgramFiles(x86)"
                    , "ProgramFiles"
                    , "SystemRoot"
                    , "SystemDrive"
                    , "ProgramData"
                    , "AllUsersProfile" ] {
        EnvGet v, %var%
        If (StartsWith(path, v)) {
            ahkDir := "%" var "%" SubStr(ahkDir, StrLen(v)+1)
        }
    }
}

#include <ExpandEnvVars>
#include <StartsWith>
