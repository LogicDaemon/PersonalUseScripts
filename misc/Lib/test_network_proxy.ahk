;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

errCURL204(url := "http://clients3.google.com/generate_204") {
    local
    curlerr := -1
    TrayTip,,Testing current environment connectivity (3s max)
    proc := {}
    SetTimer Func("killCURL").Bind(proc), -5000
    RunWait curl --connect-timeout 3 "%url%", %A_Temp%, UseErrorLevel Hide, proc.PID
    curlerr := ErrorLevel
    SetTimer killCURL, Off
    TrayTip
    return curlerr
}

KillCURL(procObjWithPID) {
    If (procObjWithPID.PID)
        Process Close, % procObjWithPID.PID
}

SetProxyEnv(proxyurl := "http://localhost:63128/") {
    local
    If (errCURL204()) { ; errCURL204() returns error
        ; removehp := RegWriteUserEnv("http_proxy", "%http_proxy_%", true)
        ; removehps := RegWriteUserEnv("https_proxy", "%https_proxy_%", true)
        ; If (removehp || removehps)
        ;     EnvUpdate
        ; EnvGet http_proxy, http_proxy_
        ; EnvGet https_proxy, https_proxy_
        Run %comspec% /C "%USERPROFILE%\Documents\Scripts\cntlm.cmd",,Min
        EnvSet http_proxy, %proxyurl%
        EnvSet https_proxy, %proxyurl%
        
        return !errCURL204()
    }
}
