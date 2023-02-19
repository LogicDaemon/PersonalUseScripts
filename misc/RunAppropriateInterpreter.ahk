#NoTrayIcon
#ErrorStdOut
#NoEnv
SetBatchLines -1

If ( %0% == 0 ) {
    MsgBox 68, Replace .cmd association with this script?,
(
This script used to be associated with .cmd files
instead of default windows batch interpreter (%comspec%)
to try to detect type of file and run appropriate interpreter
),
    IfMsgBox Yes
    {
	RegRead defaultbak, HKCR, .cmd, defaultbak
	CheckError()
	If (!defaultbak) {
	    RegRead curcmd, HKCR, .cmd
	    RegWrite REG_SZ, HKCR, .cmd, defaultbak, %curcmd%
	    CheckError()
	}
	RegWrite REG_SZ, HKCR, .cmd,, AutoHotkeyOrBatch
	CheckError()
	RegWrite REG_SZ, HKCR, AutoHotkeyOrBatch\Shell\Open\Command,, "%A_AhkPath%" "%A_ScriptFullPath%" "`%1" `%*
	CheckError()
    }
    Exit
}

Loop %0%  ; For each parameter:
{
    param := %A_Index%
    IfNotInString, param, `"
	IfInString, param, %A_Space%
	    param := """" . param . """"
    params .= param . A_Space
;    If 0 > %A_Index%
;	params .= A_Space
}

InterpAHK = "%A_AhkPath%"
InterpCMD = %comspec% /C

FileRead SigCheck, *m3 %1%
IF ( !StrLen(SigCheck) ) ;UTF-8 Signature won't be read
    Interpreter = %InterpAHK%
Else
    Loop Read, %1%
    {
	; cmd
	MatchLine=A_LoopReadLine ;AutoTrim works
	If ( RegExMatch(MatchLine, "iSX)^:[^[:space:]]")		; :label
	  || RegExMatch(MatchLine, "iSX)^[""]?[[:alpha:]]:\\")		; d:\
	  || RegExMatch(MatchLine, "iSX)^[""]?\\\\[^[:space:]]+\\")	; \\server\
	  || RegExMatch(MatchLine, "iSX)^REM")				; REM
	  || RegExMatch(MatchLine, "iSX)^SET \w") )			; SET
	{
	    Interpreter = %InterpCMD%
	    Break
	}

	; AutoHotkey
	If ( RegExMatch(MatchLine, "iSX)^;")				; ;
	  || RegExMatch(MatchLine, "iSX)^{")				; {
	  || RegExMatch(MatchLine, "iSX)^}")				; }
	  || RegExMatch(MatchLine, "iSX)^[^[:space:]]+::")		; key::
	  || RegExMatch(MatchLine, "iSX)^[^[:space:]]+:$")		; label:
	  || RegExMatch(MatchLine, "iSX)^#\w")				; #option
	  || RegExMatch(MatchLine, "iSX)^\w,") )			; operator,
	{
	    Interpreter=%InterpAHK%
	    Break
	}
    }

If (!Interpreter) {
    TrayTip Running CMD determining if it is batch or AHK, No rule matched. Using default – %InterpCMD%, 5, 2
    Interpreter = %InterpCMD%
}

;MsgBox 
Run %Interpreter% %params%
Exit

CheckError() {
    If ErrorLevel
	MsgBox Error: %ErrorLevel%
}
