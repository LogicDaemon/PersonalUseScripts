;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (A_Args.Length() == 1)
    Exit nprivRun(fileName)

fileName := A_Args[1]
otherArgs := ""
For i, arg in A_Args {
    If (i > 1)
        otherArgs .= (InStr(arg, " ") ? """" arg """" : arg) . " "
}
Exit nprivRun(fileName, otherArgs)

#include <nprivRun>
