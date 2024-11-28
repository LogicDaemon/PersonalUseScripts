;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv

GetMailUserId(ByRef GetSharedMailUserIdScript:="") {
    EnvGet MailUserId,MailUserId
    If (MailUserId) {
	return MailUserId
    } Else {
	If (!GetSharedMailUserIdScript) {
	    EnvGet GetSharedMailUserIdScript,GetSharedMailUserIdScript
	    If (!GetSharedMailUserIdScript)
		GetSharedMailUserIdScript=%A_AppDataCommon%\mobilmir.ru\_get_SharedMailUserId.cmd
	}
	If (FileExist(GetSharedMailUserIdScript)) {
	    return ReadSetVarFromBatchFile(GetSharedMailUserIdScript, "MailUserId")
	}
    }
}

#include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
