Which(names*) {
    local
    EnvGet path, PATH
    EnvGet exts, PATHEXT
    exts := StrSplit(exts, ";")
    For _, dir in StrSplit(path, ";") {
        dir := ExpandEnvVars(dir)
        For _, name in names {
            SplitPath name,,, ext
            For _, ext in ext ? [""] : exts {
                Loop Files, % dir "\" name ext
                    Return A_LoopFileLongPath
            }
        }
    }
    Throw Exception("names were not found in PATH",, ListJoinToStr(names, ", "))
}

#include <ExpandEnvVars>
#include <ListJoinToStr>
