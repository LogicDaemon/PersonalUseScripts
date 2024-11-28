;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

updateDelay := 200 ; ms

;groupsCriteria := [{"FormatTime used for folder name, value based on first file in the group": {"TimeDiff Unit": TimeDiff_Value}}, ...]
groupsCriteria := [ {"yyyy-MM-dd": {Hours: 12}}
                 , {"yyyy-MM-dd HH-mm": {Hours: 3}}
                 , {"yyyy-MM-dd HH-mm": {Minutes: 30}}
                 , {"yyyy-MM-dd HH-mm": {Minutes: 10}}]

srcDir := A_Args[1]
While (!srcDir) {
    ;Pictures={33E28130-4E1E-4676-835A-98395C3BC3BB}
    ;PicturesLibrary={A990AE9F-A03B-4E80-94BC-9912D7504104}
    FileSelectFolder srcDir, *::{33E28130-4E1E-4676-835A-98395C3BC3BB}, 2, Из какой папки брать фото
    ; option 2 allows the user to type the name of a folder
    If (ErrorLevel)
        ExitApp 1
}

dstBaseDir := A_Args[2]
If (!dstBaseDir) {
    FileSelectFolder dstBaseDir, *%srcDir%, 2, Куда перемещать (Отмена – не перемещать`, просто показать). Лучше`, если эта папка будет на том же диске`, где и исходные файлы.
    If (!ErrorLevel && !dstBaseDir)
        MsgBox Выбранная папка не поддерживается`, будет просто выведен список файлов.
}

filestime := {}

SetWorkingDir %srcDir%
Progress A M2 ZH0, `n, Чтение списка файлов...
Loop Files, *.*, R
{
    If (filestime.HasKey(A_LoopFileTimeModified))
        filestime[A_LoopFileTimeModified].Push(A_LoopFileFullPath)
    Else
        filestime[A_LoopFileTimeModified] := [A_LoopFileFullPath]
    If (A_TickCount > nextUpdateTime) {
        nextUpdateTime := A_TickCount + updateDelay
        Progress,, %A_Index%
    }
    
    totalFiles := A_Index
}
Progress Off

; Criteria is a bit of an unusual word—while it is formally considered plural, it is often used as if it were singular. Using it as singular, though, is considered nonstandard, so beware of that. Criterion is uncommon and criterions is rare, but neither are so rarely used that I would consider them obsolete. -- https://ell.stackexchange.com/a/161
For i, groupCriteria in groupsCriteria {
    For nameFormat, groupCriterion in groupCriteria {
        groupTimes := {}, groupscount := p := 0
        For unit, value in groupCriterion {
            For t in filestime {
                ct := t
                If (p)
                    t -= p, %unit%
                If (!p || t >= value)
                    groupscount++, groupTimes[ct] := {(nameFormat): t " " unit}
                p := ct
            }
        }
    }
} Until groupscount > 1

;MsgBox % ObjectToText(groupTimes)

logfo := FileOpen(A_Temp "\" A_ScriptName "." A_Now ".log", "a-w")

fcount := "", pcount := 0
If (dstBaseDir) {
    Progress A M2 R0-%totalFiles%, `n, Перемещение файлов в папку %dstBaseDir%\дата группы\папка_исходного_файла
    For ftime, flist in filestime {
        For ct, groupTime in groupTimes {
            If (ftime >= ct) {
                For nameFormat, timeDiff in groupTime
                    FormatTime dirName, %ct%, %nameFormat%
                
                groupTimes.Delete(ct)
                report .= (fcount == "" ? "" : "перемещено файлов: " fcount "`n") . "Папка " dirName ":`n`t"
                fcount := 0
            }
            break ; one group at a time
        }
        
        For i, fpath in flist {
            SplitPath fpath,, outDir
            fullOutDir = %dstBaseDir%\%dirName%\%outDir%
            If (prevOutDir != fullOutDir) {
                logfo.Write("Creating dir """ fullOutDir """")
                Progress,,, Перемещение файлов в папку %dstBaseDir%\%dirName%
                FileCreateDir %fullOutDir%
                logfo.WriteLine(ErrorLevel ? "… error " A_LastError : "")
                prevOutDir := fullOutDir
            }
            FileMove %fpath%, %dstBaseDir%\%dirName%\%fpath%
            If (ErrorLevel) {
                logfo.WriteLine("Error moving """ fpath """ to """ dstBaseDir "\" dirName "\" fpath """")
                report .= "Ошибка " A_LastError " при попытке перемещения файла """ fpath """`n`t"
                Progress,, %fpath% – ошибка %A_LastError%
            } Else {
                fcount++, pcount++
                If (A_TickCount > nextUpdateTime) {
                    nextUpdateTime := A_TickCount + updateDelay
                    Progress %pcount%, %fpath%
                }
            }
        }
    }
    report .= "перемещено файлов: " fcount "`n"
} Else {
    report := "Всего файлов: " totalFiles ", всего групп: " groupscount "`n"
    For ct, groupTime in groupTimes {
        For nameFormat, timeDiff in groupTime {
            FormatTime dirName, %ct%, %nameFormat%
            report .= "Папка """ dirName """: первый файл – """ filestime[ct][1] """, разница с предыдущим – " timeDiff "`n"
        }
    }
}

If (report) {
    MsgBox %report%
    logfo.WriteLine(report)
}
logfo.Close()

ExitApp
