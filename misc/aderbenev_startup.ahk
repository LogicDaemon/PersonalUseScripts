#NoEnv
#SingleInstance
FileEncoding UTF-8
EnvGet LocalAppData, LocalAppData

Process Priority, % DllCall("GetCurrentProcessId"), H

Loop
{
    UnlockBDE("d:")
    If (FileExist("d:\Distributives"))
        Break
    MsgBox 0x10, BDE unlock failed, D:\Distributives not found, 10
}

Run "%A_AhkPath%" "%A_ScriptDir%\Hotkeys.ahk"

Run wsl.exe echo init complete,, Min

Run %comspec% /C "update.cmd", %LocalAppData%\Programs\SysInternals, Min
;Run "%A_AhkPath%" "%LocalAppData%\Programs\pac\wpad.js update.ahk"

Run sc.exe stop AdobeARMservice,, Min
Run sc.exe config AdobeARMservice start= disabled,, Min

GroupAdd _1password, ahk_exe 1password.exe
WinKill ahk_group _1password
Loop
{
    Process Close, 1password.exe
} Until !ErrorLevel

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

FilterProcess(ByRef fullPath) {
    local
    global ProcPri
    SplitPath fullPath, name
    Return ProcPri.HasKey(name)
}

For pid, path in ProcessList("FilterProcess") {
    SplitPath path, name
    Process Priority, %pid%, % ProcPri[name]
}

#include %A_LineFile%\..\unlockBDE.ahk
#include <ProcessList>
