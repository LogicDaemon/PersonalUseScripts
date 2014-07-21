#NoEnv

ShopBTSDir=d:\1S\Rarus\ShopBTS
PostConfigDir=%ShopBTSdir%\ExtForms\post
exe7z := find7z()

RunWait "%exe7z%" x -aoa -o"%ShopBTSdir%" -- "%A_ScriptDir%\ShopBTS_Add.7z"

IfExist %PostConfigDir%\blat.cfg
    IfNotExist %PostConfigDir%\sendemail.cfg
    {
	FileRead blatcfg, %PostConfigDir%\blat.cfg
	;blat.cfg: 
	;-f dt@k.mobilmir.ru -u dt@k.mobilmir.ru -pw KAsb23jkasH37sAs

	Loop Parse, blatcfg, %A_Space%`r,`n
	{
	    If (A_LoopField=="")
		continue
	    If nextfield
	    {
		%nextfield%=%A_LoopField%
		nextfield=
	    } Else If (A_LoopField="-f") {
		nextfield=emailFrom
	    } Else If (A_LoopField="-u") {
		nextfield=userName
	    } Else If (A_LoopField="-pw") {
		nextfield=password
	    } Else
		Throw Exception("Не удалось разобрать blat.cfg", -1, "Значения ключа """ . A_LoopField . """ неизвестно")
;		Формат файла blat.cfg не соответствует ожидаемому, автоматический перенос информации в sendemail.cfg невозможен. Выполните перенос вручную.
	}

	If Not userName
	    If emailFrom
		userName=%emailFrom%

	If (userName="" || password="")
	    Throw Exception("Не удалось разобрать blat.cfg", -1, "В файле blat.cfg не найдена необходимая информация. Запишите в sendemail.cfg вручную.")

	FileAppend %userName%`n%password%`n, %PostConfigDir%\sendemail.cfg, CP1251
    }

RunWait %comspec% /C %A_ScriptDir%\..\_shedule_rsend_queue.cmd, %A_ScriptDir%\..

find7z() {
    Try return GetPathForFile("7zG.exe", paths*)
    paths := ["c:\Program Files\7-Zip", "c:\Program Files (x86)\7-Zip", "c:\Arc\7-Zip"]
    paths.Push("D:\Distributives\Soft\utils", "W:\Distributives\Soft\utils", "\\localhost\Distributives\Soft\utils")
    Try return GetPathForFile("7za.exe", paths*)
    Try return GetPathForFile("7z.exe", paths*)
}

GetPathForFile(file, paths*) {
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%file%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw "Not found " . file
}
