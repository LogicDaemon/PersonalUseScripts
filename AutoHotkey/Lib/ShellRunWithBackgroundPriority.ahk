;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

ShellRunWithBackgroundPriority(ByRef cmdLine, ByRef dir := "", ByRef trayTipTitle := "", processWaitTimeout := 3, explorerexeWaitTimeout := 15) {
    exePath := Trim(ParseCommandLine(cmdLine)[0], """")
    SplitPath exePath, exeName, exeDir
    
    If (dir == "" && !IsByRef(dir))
        dir := exeDir
    ahkExeRunArgs = "%A_LineFile%\..\RunWithBackgroundPriority.ahk" %cmdLine%
    Loop 2
    {
        If (A_Index == 1) {
            TrayTip %trayTipTitle%, using ShellRun...
            Process Wait, explorer.exe, %explorerexeWaitTimeout%
            If (ErrorLevel) {
                ShellRun(A_AhkPath, ahkExeRunArgs, dir) ;/systemstartup
                Process Wait, %exeName%, %processWaitTimeout%
                pid := ErrorLevel
            }
        } Else {
            TrayTip %trayTipTitle%, directly via RunWait...
            RunWait "%A_AhkPath%" %ahkExeRunArgs%, %dir%, UseErrorLevel
            pid := ErrorLevel
        }
        TrayTip
    } Until pid

    Loop 2
    {
        If (A_Index == 1)
            Process Exist, ahk_pid %pid%
        Else
            Process Wait, %exeName%, 30
    } Until ErrorLevel
    return ErrorLevel
}

#include %A_LineFile%\..\ShellRun from Installer.ahk
#include <ParseCommandLine>
