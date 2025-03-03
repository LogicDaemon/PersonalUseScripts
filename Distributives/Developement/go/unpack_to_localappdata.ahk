;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

#include <find7zexe>

verInstalled := 0
Loop Files, %LocalAppData%\Programs\go-*, D
{
    If (RegexMatch(A_LoopFileName, "go-(1\..*)", verN)
        && VersionCompare(verN1, verInstalled, False)) {
        verInstalled := verN1
    }
}
verLatest := 0
Loop Files, go1.*.windows-amd64.*
{
    If (RegexMatch(A_LoopFileName, "^go(\d+(?:.\d+)+).*\.(?:zip|7z)$", verN) ; windows-amd64\." ext
        && VerCompare(verN1, ">" verLatest)) {
        pathLatest := A_LoopFileFullPath
        verLatest := verN1
    }
}
If (VersionCompare(verLatest, verInstalled, False)) {
    newVerDir = %LocalAppData%\Programs\go-%verLatest%
    Run "%exe7z%" x -aoa -o"%newVerDir%" -- "%pathLatest%"
    UpdateJunction(newVerDir "\go", LocalAppData "\Programs\go")
    ; SetEnvVarIfDiffers("GOROOT", "%LOCALAPPDATA%\Programs\go")
    Run compact.exe /C /S /EXE:LZX "%newVerDir%", %newVerDir%, Min
}
ExitApp

UpdateJunction(newVerDir, destDir) {
    Local
    If (FileExist(destDir ".new")) {
        FileAppend "%destDir%.new" exists`, removing`n, *, CP1
        FileRemoveDir %destDir%.new
        If (ErrorLevel) {
            FileAppend "%destDir%.new" removal failed`n, *, CP1
            ExitApp %ErrorLevel%
        }
    }
    RunWait %comspec% /C "MKLINK /J "%destDir%.new" "%newVerDir%"",,Min UseErrorLevel
    If (ErrorLevel) {
        FileAppend Failed creating reparse point`n, *, CP1
        ExitApp %ErrorLevel%
    }
    FileRemoveDir %destDir%
    If (FileExist(destDir)) {
        FileAppend Failed removing %destDir%`n, *, CP1
        ExitApp ErrorLevel ? ErrorLevel : 128
    }
    FileMoveDir %destDir%.new, %destDir%, R
}

SetEnvVarIfDiffers(name, value) {
    Local
    ; Check the current environment variables
    EnvGet curValue, %name%
    If (curValue = value)
        Return
    ; Check the user environment variables set in the registry
    RegRead curValue, HKCU, Environment, %name%
    If (curValue = value)
        Return
    If (!curValue) { ; if the user environment variable is not set
        ; Check the system environment variables set in the registry
        RegRead curValue, HKLM, SYSTEM\CurrentControlSet\Control\Session Manager\Environment, %name%
        If (curValue = value)
            Return
    }
    RegWrite REG_EXPAND_SZ, HKCU, Environment, %name%, %value%
    EnvUpdate
}
