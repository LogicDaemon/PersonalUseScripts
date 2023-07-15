;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet SystemDrive,SystemDrive

Loop Files, %A_ScriptDir%\*.dsc.txt, R
{
    foundURL := 0
    Loop Read, %A_LoopFileFullPath%
    {
        
        If (foundURL) {
            URL := A_LoopReadLine
            break
        } Else If (A_LoopReadLine="This file has been downloaded from:") {
            foundURL := 1
        }
    }
    pathLog := SubStr(A_LoopFileFullPath, 1, -StrLen(".dsc.txt")) . ".log"
    Run "%LocalAppData%\Programs\SysUtils\wget.exe" -o "%pathLog%" -N "%URL%", %A_LoopFileDir%, Min
}
