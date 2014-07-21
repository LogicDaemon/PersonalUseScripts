#NoEnv

RapidaDistDestination=d:\Distributives\Soft_officeonly\Specialized\Rapida

SetWorkingDir %A_ScriptDir%

If A_ScriptDir!=%RapidaDistDestination%
{
RetryCreatingDir:
    FileCreateDir %RapidaDistDestination%
    If ErrorLevel
    {
	MsgBox 6, Ошибка при копировании дистрибутива, При создании папки`n%RapidaDistDestination%`nпрозошла ошибка`, поэтому скопировать дистрибутив не получится. Можно продолжить без копирования дистрибутива`, в этом случае обновления тоже будут запускаться из текущего пути.`nТекущий путь: %A_ScriptDir%
	IfMsgBox Cancel
	    Exit
	IfMsgBox TryAgain
	    GoTo RetryCreatingDir
	IfMsgBox Continue
	    GoTo SkipCopyingDistributive
    }
RetryCopyFiles:
    FileCopy *.*,%RapidaDistDestination%,1
    If ErrorLevel
    {
	MsgBox 6, Ошибка при копировании дистрибутива, При копировании файлов дистрибутива в папку`n%RapidaDistDestination%`nпрозошла ошибка. Можно продолжить без копирования дистрибутива`, в этом случае обновления тоже будут запускаться из текущего пути.`nТекущий путь: %A_ScriptDir%
	IfMsgBox Cancel
	    Exit
	IfMsgBox TryAgain
	    GoTo RetryCopyFiles
	IfMsgBox Continue
	    GoTo SkipCopyingDistributive
    }
    SetWorkingDir %RapidaDistDestination%
}

SkipCopyingDistributive:

RunWait PMSetup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /LOADINF="pmsetup.inf"
If MaxErrorLevel<%ERRORLEVEL%
    MaxErrorLevel=%ERRORLEVEL%

CopyPaymMasterFrom("\\AcerAspire7720G\Projects\Рапида\PaymMaster") || CopyPaymMasterFrom("\\AcerAspire7720G.office0.mobilmir\Projects\Рапида\PaymMaster") || MsgBox Не удалось скопировать дополнительные файлы PaymMaster

RunWait install.cmd,d:\Program Files\Rapida\PaymMaster,UseErrorLevel
If MaxErrorLevel<%ERRORLEVEL%
    MaxErrorLevel=%ERRORLEVEL%

RunWait schtasks.exe /Create /TN Rapida_Update /SC ONSTART /TR "%A_ScriptDir%\update.cmd",%A_ScriptDir%,UseErrorLevel
RunWait schtasks.exe /Change /TN Rapida_Update /SC ONSTART /TR "%A_ScriptDir%\update.cmd",%A_ScriptDir%,UseErrorLevel
If MaxErrorLevel<%ERRORLEVEL%
    MaxErrorLevel=%ERRORLEVEL%

Exit %MaxErrorLevel%

CopyPaymMasterFrom(source) {
    IfExist %source%
    {
	FileCopyDir %source%,d:\Program Files\Rapida\PaymMaster,1
	return !ErrorLevel
    } Else
	return 0
}
