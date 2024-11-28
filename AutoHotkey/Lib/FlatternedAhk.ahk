;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ReFlatternAhk(ByRef src) {
    local
    global includeFiles := {}
    
    FileDelete %src%.tmp
    ininc := 0
    Loop Read, %src%, %src%.tmp
    {
        If (ininc) {
            If (A_LoopReadLine ~= "SA); --FlatternAhk-- end of: " EscapeRegex(ininc) "$")
                ininc := ""
        } Else If (RegexMatch(A_LoopReadLine, "SAi); --FlatternAhk-- #include (?P<path>.+)", m)) {
            ininc := mpath
            FileAppend % FlatternedAhk(NormalizedPath(mpath, {A_LineFile: src}))
        } Else {
            If (ininc == "") {
                If (Trim(A_LoopReadLine) && !(A_LoopReadLine ~= "SA); --FlatternAhk-- Duplicate include detected: "))
                    ininc := 0
                Else
                    continue
            }
            FileAppend %A_LoopReadLine%`n
        }
    }
    idx=
    Loop
        FileMove %src%, %src%.bak%idx%
    Until !ErrorLevel, idx := A_Index
    FileMove %src%.tmp, %src%
}

FlatternedAhk(path) {
    local
    global includeFiles
    If (includeFiles.HasKey(path)) {
        return "; --FlatternAhk-- Duplicate include detected: " path "`n"
    } Else {
        includeFiles[path] := 1
        out := "; --FlatternAhk-- #include " path "`n"
        
        Loop Read, % path
            out .= RegexMatch(A_LoopReadLine, "SAi)\s*#include (?P<optn>\*\S*)?(?P<path>.+)", m) ? FlatternedAhk(NormalizedPath(mpath, {A_LineFile: path})) : A_LoopReadLine "`n"
        return out "; --FlatternAhk-- end of: " path "`n`n"
    }
}

NormalizedPath(ByRef path, expandSubst := "") {
    local
    Loop Files, % ExpandMod(path, expandSubst)
        return A_LoopFileLongPath
    return path
}

#include %A_LineFile%\..\ExpandMod.ahk
#include %A_LineFile%\..\EscapeRegex.ahk
