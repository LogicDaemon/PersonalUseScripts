#NoEnv
FileAppend Searching 7-Zip... ,*,CP1
#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
Try exe7z:=find7zexe("7zg.exe")

If (!exe7z)
    MsgBox 7-Zip не найден. Сообщите технической поддержке.

target=d:\Program Files\Credit
IfNotExist %target%
    MsgBox Папка, в которой должен располагаться установленное ПО банка РС, не существует. Сообщите технической поддержке.

FileRemoveDir %target%\.bak,1
FileCreateDir %target%\.bak
FileMove %target%\*, %target%\.bak\*.*, 1
Loop %target%\*, 2
    FileMoveDir %A_LoopFileFullPath%, %target%\.bak\%A_LoopFileName%, R

RunWait "%exe7z%" x -o"%target%" -- "%A_ScriptDir%\Credit.7z"
If ErrorLevel
    MsgBox Во время распаковки архива произошла ошибка. ПО Credit`, вероятно`, неработоспособно. Проверьте`, не отключилось ли VPN-соединение`, и попробуйте ещё раз. Если проблема повторится`, делайте задачу.
Else {

    RegRead PointCode, HKEY_CURRENT_USER, Software\RS\Credit\Enter, OnLine
    If (ErrorLevel || !PointCode)
	MsgBox Программное обеспечение заменено (переустановлено)`, но код точки не указан.`n`nБез кода точки оформление договоров работать не будет.`nВыберите в меню программы «Инструменты» → «Точка ввода»`, чтобы указать код точки.
}
