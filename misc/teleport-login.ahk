;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Files, %LocalAppData%\_sec\teleport*.txt
{
	secretPath := A_LoopFileFullPath
	teleporthost := SubStr(A_LoopFileName, 1, -StrLen(A_LoopFileExt)-1)
	Break
}
FileReadLine password, %secretPath%, 1
Random q
tmpPath=%A_Temp%\totp_token_%q%.txt
RunWait %comspec% /C "py "%A_ScriptDir%\py\totp_token.py" "%secretPath%" "2" >"%tmpPath%"", %A_Temp%, Hide
FileRead totpToken, %tmpPath%
FileDelete %tmpPath%

Run %comspec% /K "tsh login "--proxy=%teleporthost%:443" --auth=local "--user=%A_UserName%" || PAUSE & ECHO Exiting in 10s & PING -n 10 127.0.0.1 >NUL 2>&1 & EXIT", ,, tshPID
; "%teleporthost%"
;WinWait ahk_pid %tshPID%
;MsgBox %password%
WinWaitActive C:\WINDOWS\system32\cmd.exe - tsh  login "--proxy=%teleporthost%:443" --auth=local "--user=%A_UserName%"  ahk_pid %tshPID%
Sleep 2000
Loop Parse, password
{
	If (!WinActive())
		ExitApp
	SendInput {raw}%A_LoopField%
	Sleep 100
}
ControlSend,, {Enter}
Sleep 1000
Loop Parse, totpToken
{
	If (!WinActive())
		ExitApp
	SendInput {raw}%A_LoopField%
	Sleep 100
}
ControlSend,, {Enter}
