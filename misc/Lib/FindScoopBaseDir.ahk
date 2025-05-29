FindScoopBaseDir() {
    local
    EnvGet path, PATH
    For _, dir in StrSplit(path, ";") {
        dir := ExpandEnvVars(dir)
        If (FileExist(dir "\scoop.cmd") || FileExist(dir "\scoop.ps1")) {
            Loop Files, % dir "\..", D
                return A_LoopFileLongPath
        }
    }
    Throw Exception("Scoop not found in PATH")
}

;MsgBox % "Found: " FindScoopBaseDir()
#include <ExpandEnvVars>
