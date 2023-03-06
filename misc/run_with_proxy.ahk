#NoEnv
#NoTrayIcon
#SingleInstance ignore

timeout := 3
curlerr := -1
TrayTip,,Testing current environment connectivity (3s max)
SetTimer killCURL, % -500-timeout*1000
RunWait curl --connect-timeout %timeout% http://clients3.google.com/generate_204, %A_Temp%, UseErrorLevel Hide, curlPID
curlerr := ErrorLevel
SetTimer killCURL, Off
TrayTip

If (curlerr) {
    Run %comspec% /C "%USERPROFILE%\Documents\Scripts\cntlm.cmd",,Min
    http_proxy := https_proxy := "http://127.0.0.1:63128/"
    EnvSet http_proxy, %http_proxy%
    EnvSet https_proxy, %https_proxy%
}
RunWait % ParseScriptCommandLine(),, UseErrorLevel
Exit ErrorLevel

killCURL:
    Process Close, %curlPID%
ExitApp

#include <RegWriteUserEnv>
#include <ParseScriptCommandLine>
