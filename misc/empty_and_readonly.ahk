;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance off

IfGreater 0,1
{
    MsgBox 33, Confirm files action, %0% files will be made empty!
    IfMsgBox OK
	dontask=1
}

Loop %0% {
    FileName := %A_Index%
    Loop %FileName%
    {
	FileAttr := FileExist(A_LoopFileFullPath)
	If ( FileAttr && !InStr(FileAttr, "R", true) ) {
	    If Not dontask
	    {
		MsgBox 33, Confirm file action, File will be made empty:`n%A_LoopFileFullPath%
		IfMsgBox Cancel
		    Continue
	    }
	    File := FileOpen(A_LoopFileFullPath, 0x1)
	    File.Close()
	    FileSetAttrib +R, %A_LoopFileFullPath%
	}
    }
}
