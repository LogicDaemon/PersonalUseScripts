;unlicense (http://unlicense.org/) public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet UserProfile,USERPROFILE

; .shim example (args are optional):
; path = "%LOCALAPPDATA%\Programs\Total Commander\TOTALCMD64.EXE"
; args = /S=L
Loop Files, *.shim-template
{
    Try {
        ProcessShim(A_LoopFileFullPath)
    } Catch e {
        MsgBox, 16, Error processing %A_LoopFileFullPath%, % e.what "`n`n" e.message "`n`n" e.extra
    }
}
RunWait dfhl.exe /l ., %LocalAppData%\Programs\scoop\shims, Min

ProcessShim(ByRef shim) {
    local
    SplitPath shim,,,, name
    path := ""
    args := ""

    Loop Read, %shim%
    {
        eqPos := InStr(A_LoopReadLine, "=")
        key := Trim(SubStr(A_LoopReadLine, 1, eqPos-1))
        value := Trim(SubStr(A_LoopReadLine, eqPos+1))

        If (key = "path") {
            If (path) ; multiple paths are variants, ordered by preference
                Continue
            value := Trim(value, """")
            If (!FileExist(value))
                value := ExpandEnvVars(value)
            Loop Files, %value%
            {
                value := A_LoopFileFullPath
                Break
            }
            If (!FileExist(value))
                Continue
            path := value
        } Else If (key = "args") {
            If (args)
                Throw Exception("Multiple ""args"" in " shim,, "1) " args "`n2) " value)
            args := value
        } Else {
            Throw Exception("Unknown key """ key """ in " shim,, A_LoopReadLine)
        }
    }
    If (!path)
        Throw Exception("No valid ""path"" found in " shim)

    If A_Space in name
        name := """" name """"
    RunWait %comspec% /C "scoop shim add %name% "%path%" -- %args% >"%A_Temp%\shim_add_%name%.log" 2>&1",, Hide
    If (ErrorLevel) {
        Run *Open "%A_Temp%\shim_add_%name%.log"
        Throw Exception("Error adding shim for " name,, "ErrorLevel=" ErrorLevel)
        ExitApp
    }
}
