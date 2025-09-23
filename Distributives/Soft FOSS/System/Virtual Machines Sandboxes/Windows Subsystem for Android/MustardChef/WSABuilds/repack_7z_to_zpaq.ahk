;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

#include <find7zexe>

backupWD := A_WorkingDir
SetWorkingDir %A_ScriptDir%

; files:
; WSA_2407.40000.4.0_x64_Release-Nightly-with-KernelSU-v1.0.2-GApps-13.0-NoAmazon.7z
; WSA_2407.40000.4.0_x64_Release-Nightly-with-magisk-28.1.28100.-stable-GApps-13.0-NoAmazon.7z
; WSA_2407.40000.4.0_x64_Release is prefix

; prefix → [files]
filesByPrefix := {}
Loop Files, WSA_*.7z
{
    If (!RegExMatch(A_LoopFileName, "^(?P<Prefix>[^-]+)", m))
        Continue
    
    If (filesByPrefix.HasKey(mPrefix))
        filesByPrefix[mPrefix].Push(A_LoopFileName)
    Else
        filesByPrefix[mPrefix] := [A_LoopFileName]
}

For prefix, files in filesByPrefix {
    ; RunWait, Target [, WorkingDir, Max|Min|Hide|UseErrorLevel, OutputVarPID]
    For _, file in files {
        ; SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
        SplitPath file,,,, name
        RunWait "%exe7z%" x -aoa -y -o"%A_Temp%\%prefix%\%name%" -- "%prefix%-*.7z",, Min UseErrorLevel
        If (ErrorLevel)
            ErrorExit(ErrorLevel, "Failed to extract files for prefix """ prefix """", A_Temp "\" prefix)
    }
    Process Priority,, BelowNormal
    RunWait %comspec% /C ""%LocalAppData%\Programs\7-max\7maxc.exe" zpaq64 a "%A_WorkingDir%\%prefix%.m4.zpaq" * -m4 >>"%A_WorkingDir%\%prefix%.m4.zpaq.log" 2>&1 && (CD .. & RD /S /Q "%prefix%")", %A_Temp%\%prefix%, Min UseErrorLevel
    If (ErrorLevel)
        ErrorExit(ErrorLevel, "Failed to pack files for prefix """ prefix """", A_Temp "\" prefix)
}

SetWorkingDir %backupWD%

ExitApp

ErrorExit(err, message, removeDir := "") {
    local

    MsgBox 0x10, Error, %message%
    If (removeDir)
        FileRemoveDir %removeDir%, 1
    ExitApp %err%
}
