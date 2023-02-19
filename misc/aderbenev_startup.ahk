#NoEnv
#SingleInstance
FileEncoding UTF-8
EnvGet LocalAppData, LocalAppData

Process Priority, % DllCall("GetCurrentProcessId"), H
Run "%A_AhkPath%" "%A_ScriptDir%\Hotkeys.ahk"

Run %comspec% /C "update.cmd", %LocalAppData%\Programs\SysInternals, Min
;Run "%A_AhkPath%" "%LocalAppData%\Programs\pac\wpad.js update.ahk"

Run sc.exe stop AdobeARMservice,, Min

;ProcPri :=  { "LMS.exe": "L"
;            , "AeXNSAgent.exe": "L"
;            , "AeXAgentUIHost.exe": "L"
;            , "SCNotification.exe": "L"
;            , "CcmExec.exe": "L"
;            , "DWRCST.EXE": "L"
;            , "DWRCS.EXE": "L"
;            , "OneApp.IGCC.WinService.exe": "L"
;            , "UpdaterService.exe": "L"
;            , "igfxCUIService.exe": "L"
;            , "igfxEM.exe": "L"
;            , "IWDeployAgent.exe": "L"
;            , "powershell.exe": "L" }

;Loop 4
;{
;    remain := 0
;    For proc, pri in ProcPri {
;    If (pri) {
;            Process Priority, %proc%, %pri%
;            If (ErrorLevel)
;                ProcPri[proc] := ""
;            Else
;                remain++
;        }
;    }
;    Sleep A_Index << 10
;} Until !remain
