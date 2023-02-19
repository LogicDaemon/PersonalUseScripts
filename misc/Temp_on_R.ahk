#NoEnv

If (FileExist("R:\Temp")) {
    EnvSet TEMP, R:\Temp
    EnvSet TMP, R:\Temp
}
Run % ParseScriptCommandLine()
