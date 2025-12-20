;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RunWait net.exe start NvBroadcast.ContainerLocalSystem,, Hide

;nprivRun(fileName, otherArgs)

nprivRun(A_AhkPath, """" A_ScriptDir "\nVidia Broadcast.ahk""")
ExitApp

#include <nprivRun>
