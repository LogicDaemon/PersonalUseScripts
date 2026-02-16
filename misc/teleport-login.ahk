;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Files, %LocalAppData%\_sec\teleport*.txt
{
	teleporthost := SubStr(A_LoopFileName, 1, -StrLen(A_LoopFileExt)-1)
	FileRead password, %A_LoopFileFullPath%
}
Run %comspec% /K "tsh login "--proxy=%teleporthost%:443" --auth=local "--user=%A_UserName%" || PAUSE & ECHO Exiting in 10s & PING -n 10 127.0.0.1 >NUL 2>&1 & EXIT", ,, tshPID
; "%teleporthost%"
;WinWait ahk_pid %tshPID%
;MsgBox %password%
WinWaitActive C:\WINDOWS\system32\cmd.exe - tsh  login "--proxy=%teleporthost%:443" --auth=local "--user=%A_UserName%"  ahk_pid %tshPID%
Sleep 2000
Loop Parse, password
{
    SendInput {raw}%A_LoopField%
    Sleep 100
}
ControlSend,, {Enter}
