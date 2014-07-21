;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Read, %A_ScriptDir%\Copy photos from flash cards.destinations.txt
{
    destBase := ExpandEnvVars(A_LoopReadLine)
    SplitPath destPath,, destBaseDir
    If (FileExist(destBaseDir)) {
        FileCreateDir %destBase%
        If (ErrorLevel)
            destBase := ""
        Else
            break
    }
}
If (!destBase)
    Throw Exception("No destination available")

DriveGet disks, List, REMOVABLE
Loop Parse, disks
{
    baseDir := A_LoopField ":\DCIM"
    SetWorkingDir %baseDir%
    
    datesByExts := {}, extList := ""
    Loop Files, %baseDir%\*.*, R
    {
        filedate := SubStr(A_LoopFileTimeModified, 1, 8) ; YYYYMMDD
        If (datesByExts.HasKey(A_LoopFileExt)) {
            If (datesByExts[A_LoopFileExt].HasKey(filedate))
                continue
            Else
                datesByExts[A_LoopFileExt][filedate] := 0
        } Else {
            datesByExts[A_LoopFileExt] := {filedate: 0}, extList .= " *." A_LoopFileExt
        }
        
        nextDate := IncDate(filedate)
        destDir = %destBase%\%A_LoopFileExt%\%filedate%
        ;MsgBox nextDate: %nextDate%`nfiledate: %filedate%`ndestDir: %destDir%`ndestBase: %destBase%`n%A_LoopFileLongPath%`n%A_LoopFileFullPath%
        FileCreateDir %destDir%
        RunWait robocopy.exe "%baseDir%" . "*.%A_LoopFileExt%" /S /DCOPY:DAT /MINAGE:%nextDate% /MAXAGE:%filedate%, %destDir%, Min

        ;robocopy /?
        ;  /MAXAGE:n :: MAXimum file AGE - exclude files older than n days/date.
        ;  /MINAGE:n :: MINimum file AGE - exclude files newer than n days/date.
        ;  /MAXLAD:n :: MAXimum Last Access Date - exclude files unused since n.
        ;  /MINLAD:n :: MINimum Last Access Date - exclude files used since n.
        ;               (If n < 1900 then n = n days, else n = YYYYMMDD date).
        ;actually working: robocopy g: . /minage:20201128 /maxage:20201127 -- to only copy files since 20201127 start until 20201128 start
    }
    If (FileExist(baseDir "\*")) { ; Copy extensionless files
        Run robocopy.exe "%baseDir%" "%destBase%\no_ext" /S /DCOPY:DAT /XF %extList%
    }
}

IncDate(date) {
    date += 1, Days
    return SubStr(date, 1, 8) ; YYYYMMDD only
}

#include <ExpandEnvVars>
