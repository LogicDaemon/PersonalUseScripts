;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force

EnvGet LocalAppData,LocalAppData
EnvGet SystemDrive,SystemDrive

subdir := A_Is64bitOS ? "x64" : "Win32"

;removedriveexe = %LocalAppData%\Programs\SysUtils\uwe-sieber.de\%subdir%\RemoveDrive.exe
;ejectMediaexe = %LocalAppData%\Programs\SysUtils\uwe-sieber.de\%subdir%\EjectMedia.exe
;%SystemDrive%\SysUtils\UnxUtils\Uri\eject.exe

If (A_Args.Length()) {
    For i, arg in A_Args
	Run "%removedriveexe%" %arg% -b -e -i
} Else {
    Progress zh0 B,`n`n`n, Alpha key to Remove Drive`,`nany other to cancel`,`nor just wait 3s
    SetTimer End, 3000
    OutputVar=
    Input key, B I L1 M T3, {Escape}
    If (ErrorLevel != "Max") ; Max = max input length, which is 1 character
        ExitApp
    SetTimer End, Off
    ;MsgBox key=%key%`nErrorLevel=%ErrorLevel%
    
    progressText=Ejecting… 
    If (key >= "a" && key <= "z") {
        ;RunWait "%ejectMediaexe%" %key%,,UseErrorLevel
        Progress,,%progressText%, Removing %key%:
        EjectMedia(key), progressText .= ErrorLevelToText(ErrorLevel)
        Progress,,%progressText%
        If (FileExist(key ":\")) {
            progressText .= "`nIssuing safe removal…"
            Progress,,%progressText%
            Try {
                SafelyRemove(key, True), progressText .= "OK"
            } Catch e {
                progressText .= e.Message, ErrorLevel := 1
                
            }
            Progress,,%progressText%
            ;Run "%removedriveexe%" %key%
        }
    }
    If (ErrorLevel)
        Sleep 3000
    Progress Off
}

End:
ExitApp

ErrorLevelToText(errlevel) {
    If (!errlevel)
        return "OK"
    Else
        return "failed, " A_LastError " (errorlevel " errlevel ")"
}

#include <EjectMedia>
#include <SafelyRemove>
