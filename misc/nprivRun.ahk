;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

fileName := A_Args[1]

If (A_Args.Length() == 1)
    Exit nprivRun(fileName)

otherArgs := ""
For i, arg in A_Args {
    If (i > 1)
        otherArgs .= (InStr(arg, " ") ? """" arg """" : arg) . " "
}
Exit nprivRun(fileName, otherArgs)

#include <nprivRun>
