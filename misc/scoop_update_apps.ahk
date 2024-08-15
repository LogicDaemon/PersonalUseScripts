;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

FileRead scoop_noautoupdate_txt, %LocalAppData%\Programs\scoop\apps\_noautoupdate.txt
scoop_noautoupdate := {}
For _, line in StrSplit(scoop_noautoupdate_txt, "`n") {
    If (line)
        scoop_noautoupdate[line] := ""
}
scoop_noautoupdate_txt=

scoopBaseDir := FindScoopBaseDir()

;RunWait scoop.cmd update -a,, Min
Loop Files, % scoopBaseDir "\apps\*.*", D
{
    If (!scoop_noautoupdate.HasKey(A_LoopFileName)) {
        RunWait scoop.cmd update "%A_LoopFileName%",, Min
        RunWait scoop.cmd cleanup "%A_LoopFileName%",, Min
    }
}
Run "%A_AhkPath%" "%A_ScriptDir%\scoop_remove_old_versions_from_cache.ahk"
Run "%LocalAppData%\Programs\DFHL_2.6\DFHL.exe" /l ., %LOCALAPPDATA%\Programs\scoop\shims, Min
Exit

#include <FindScoopBaseDir>
