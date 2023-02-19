;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

killProcesses := [ "conhost.exe"
                 , "git.exe" ]

For i, procName in killProcesses {
    WinKill ahk_exe %procName%,,5
    While true {
        Process Exist, %procName%
        If (!ErrorLevel)
            break
        If (prevPID == ErrorLevel) {
            RunWait taskkill.exe /IM %procName% /F,, Min UseErrorLevel
            break
        } Else {
            prevPID := ErrorLevel
            Process Close, %procName%
        }
    }
}
