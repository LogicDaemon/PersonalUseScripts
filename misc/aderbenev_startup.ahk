#NoEnv
#SingleInstance
FileEncoding UTF-8
EnvGet LocalAppData, LocalAppData

selfPID := DllCall("GetCurrentProcessId")
Process Priority, %selfPID%, H

Loop
{
    UnlockBDE("d:")
    If (FileExist("d:\Distributives"))
        Break
    MsgBox 0x10, BDE unlock failed, D:\Distributives not found, 10
}

Run "%A_AhkPath%" "%A_ScriptDir%\Hotkeys.ahk"

Run wsl.exe echo init complete,, Min

;Run %comspec% /C "update.cmd", %LocalAppData%\Programs\SysInternals, Min
;Run "%A_AhkPath%" "%LocalAppData%\Programs\pac\wpad.js update.ahk"

Run sc.exe stop AdobeARMservice,, Min
Run sc.exe config AdobeARMservice start= disabled,, Min

GroupAdd _1password, ahk_exe 1password.exe
WinKill ahk_group _1password
Loop
{
    Process Close, 1password.exe
} Until !ErrorLevel

Process Priority, %selfPID%, B
For dirName, params in { A_ProgramFiles "\NVIDIA Corporation\NVIDIA Broadcast": ["NVIDIA Broadcast.exe", "--process-start-args ""--launch-hidden"""]
                  , A_ProgramFiles "\NVIDIA Corporation\NVIDIA Broadcast": ["NVIDIA Broadcast UI.exe", "-minimized"]} {
    fileName := params[1]
    If (!FileExist(dirName "\" fileName))
        Continue
    Process Exist, %fileName%
    If (ErrorLevel)
        Continue
    args := params[2]
    Run "%fileName%" %args%, %dirName%
}

ProcPri :=  { "LMS.exe": "L"
            , "AeXNSAgent.exe": "L"
            , "AeXAgentUIHost.exe": "L"
            , "SCNotification.exe": "L"
            , "CcmExec.exe": "L"
            , "DWRCST.EXE": "L"
            , "DWRCS.EXE": "L"
            , "OneApp.IGCC.WinService.exe": "L"
            , "UpdaterService.exe": "L"
            , "igfxCUIService.exe": "L"
            , "igfxEM.exe": "L"
            , "IWDeployAgent.exe": "L"
            , "powershell.exe": "L" }


For pid, path in ProcessList("FilterProcess") {
    SplitPath path, name
    Process Priority, %pid%, % ProcPri[name]
}

ExitApp

FilterProcess(ByRef fullPath) {
    local
    global ProcPri
    SplitPath fullPath, name
    Return ProcPri.HasKey(name)
}
#include %A_LineFile%\..\unlockBDE.ahk
#include <ProcessList>
