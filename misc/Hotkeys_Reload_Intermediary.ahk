#NoEnv

RunWithStdin( A_AhkPath " """ A_ScriptDir "\Hotkeys.ahk"" *" ; "*" indicates that password should be read from stdin
            , ReadSlowly(CmdlArgs(1)[1]) )
ExitApp
