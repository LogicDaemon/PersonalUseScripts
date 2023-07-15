#NoEnv

PrependPaths() {
    EnvGet LocalAppData, LocalAppData
    EnvGet prefPaths, PATH

    f := FileOpen(LocalAppData "\Programs\vscode_launch_morepaths.txt", "r")
    if (!IsObject(f))
        return
    while !f.AtEOF {
        path := ExpandEnvVars(RTrim(f.ReadLine(), "`r`n"))
        Loop Files, %path%, D
            prefPaths := A_LoopFileLongPath ";" prefPaths
    }
    f.Close()

    EnvSet PATH, %prefPaths%
}

#include <ExpandEnvVars>
