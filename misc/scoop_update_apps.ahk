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

scoop_postupdate_scripts := {"python": "install-pep-514.reg"}

scoopBaseDir := FindScoopBaseDir()

;RunWait scoop.cmd update -a,, Min
Loop Files, % scoopBaseDir "\apps\*.*", D
{
    If (!scoop_noautoupdate.HasKey(A_LoopFileName)) {
        RunWait scoop.cmd update "%A_LoopFileName%",, Min
        If (A_ErrorLevel)
            Continue
        RunWait scoop.cmd cleanup "%A_LoopFileName%",, Min
        postupdate_script := scoop_postupdate_scripts[A_LoopFileName]
        If (postupdate_script) {
            SplitPath postupdate_script,,, script_ext
            If (script_ext = "reg")
                RunWait REG IMPORT "%A_LoopFileFullPath%\current\%postupdate_script%",, Min
            Else If (script_ext = "ahk")
                Run "%A_AhkPath%" "%A_LoopFileFullPath%\current\%postupdate_script%"
            Else
                Run "%A_LoopFileFullPath%\current\%postupdate_script%"
        }
    }
}
Run "%A_AhkPath%" "%A_ScriptDir%\scoop_remove_old_versions_from_cache.ahk"
Run DFHL.exe /l ., %LOCALAPPDATA%\Programs\scoop\shims, Min
ExitApp

#include <FindScoopBaseDir>
