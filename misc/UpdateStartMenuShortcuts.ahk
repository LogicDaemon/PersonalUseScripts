;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; dir :  { ext: rec, ext: rec
;        , ".": rec
;        , (dir "\"): rec
;        , ...} }
; excluded_dir may be absolute or just leaf dir name
; rec:
;   "" – no change (no recursion for . by default),
;   int – if the extension is found in current dir, then for current dir, or for the specific dir if there's "\" at end or name,
;           limit recursion depth to specified.
;           For directories, 0 to exclude them.
lookDirsLAD := { "Scripts":    { "cmd": "", "ahk": ""}
	       , "Programs":   { "exe": "", "cmd": "", "ahk": "", "lnk": ""
                               , ".": 0           ; "": subdir depth initial limit
                               , "*\" : { "exe": 0, "cmd": "", "ahk": 0, "lnk": 0
                                        , ".": 3    ; "": subdir depth initial limit
                                        , "1C\": 0 ; "\": directory exclusions
                                        , "Tor Browser\": 0
                                        , "Chromium"\: 0 } } }

For dir, params in lookDirsLAD {
    CreateDirShortcuts(A_Programs "\LocalAppData\" dir, LocalAppData "\" dir, params)
}

ExitApp

CreateDirShortcuts(ByRef dest, ByRef dir, ByRef params, curDepth := 0, filterDirs := "") {
    local
    If (!IsObject(filterDirs)) {
        expandedDirs := {}
        , uppercaseDirs := {}
        For dirName, mode in params["\"] {
            uppercaseDirs[StrUpper(dirName)] := mode
            If (!PathIsAbsolute(dirName))
                expandedDirs[StrUpper(dir "\" dirName)] := mode
        }
        params["\"] := uppercaseDirs 
        , params["\\"] := expandedDirs
        , uppercaseDirs := expandedDirs := ""
    }

    recurse := params[""] > curDepth
    FileRemoveDir %dest%, 1
    destDirRemoved := true
    SetWorkingDir %dir%
    MsgBox %dir%
    
    subdirs := {}
    Loop Files, *.*, % recurse ? "FD" : ""
    {
        If (recurse && InStr(A_LoopFileAttrib, "D")) {
            If (      params["\" ].HasKey( lfnU := StrUpper(A_LoopFileName)) )
                v :=  params["\" ][ lfnU ]
            Else If ( params["\" ].HasKey( lflpU := StrUpper(A_LoopFileLongPath)) )
                v :=  params["\" ][ lflpU ]
            Else If ( params["\\"].HasKey(lflpU) )
                v :=  params["\\"][ lflpU ]
            Else
                v := ""
            addDir := true
            If v is Integer
                If v==0
                    addDir := false
            If (addDir)
                subdirs[A_LoopFileName] := v
        } Else If (A_LoopFileExt && params.HasKey(A_LoopFileExt)) {
            SplitPath A_LoopFileName,,,, nameNoExt
            If (destDirRemoved) {
                destDirRemoved := false
                FileCreateDir %dest%
            }
            FileCreateShortcut %A_LoopFileLongPath%
                , % dest "\" LTrim(params[A_LoopFileExt] " " nameNoExt) ".lnk"
                , %dir%\%A_LoopFileDir%
                ,, (auto-created by %A_ScriptFullPath%)
	}
    }
    
    If (recurse)
        For subdir, mode in subdirs
            If mode is Integer
                CreateDirShortcuts(dest "\" subdir, dir "\" subdir, params, params[""] - mode)
            Else
                CreateDirShortcuts(dest "\" subdir, dir "\" subdir, params, curDepth)
}

PathIsAbsolute(ByRef dirName) {
    marker := SubStr(dirName, 2, 1)
    return marker==":" || marker == "\"
}

StrUpper(ByRef str) {
    return Format("{:U}", str)
}
