#NoEnv

pathPrefix := "%LOCALAPPDATA%\Programs\scoop\apps\git\current\usr\bin\"
shimSuffix := ".shim-template"

names := []
For _, v in [1, 224, 256, 384, 512] {
    names["sha" v "sum"] := "exe"
}

For name, ext in names {
    shimPath := A_ScriptDir "\" name shimSuffix
    If (FileExist(shimPath))
        Continue
    exePath := pathPrefix name "." ext
    If (!FileExist(ExpandEnvVars(exePath)))
        Continue
    FileAppend path="%exePath%"`n, %shimPath%
}
