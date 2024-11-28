;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If WinExist("ahk_exe outlook.exe") {
    WinActivate
    ExitApp
}

Run "%A_ProgramsCommon%\Outlook.lnk"
