;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

            ; dir : {  ext: "", ext: ""
            ;        , "": Loop Files,, → options
            ;        , "\": {  dir_exclusion: ""
            ;                , dir_exclusion2: "", ...} }
lookDirs := {  (LocalAppData "\Scripts"): {"cmd": "", "ahk": "", "": ""}
	     , (LocalAppData "\Programs"): { "exe": "", "cmd": "", "ahk": "", "lnk": ""
                                              , "": "2"             ; "": recursion limit
                                              , "\": { "\1C": "" ; "\": directory exclusions
                                                     , "\Tor Browser\Browser\TorBrowser": ""
                                                     , "\Chromium": ""} } }

dest := A_Programs "\LocalAppData"
FileRemoveDir %dest%, 1
FileCreateDir %dest%

For dir, params in lookDirs {
    SplitPath dir, dirName
    CreateDirShortcuts(dest "\" dirName, dir, params)
}

ExitApp

CreateDirShortcuts(ByRef dest, ByRef dir, ByRef params, depth := 0) {
    recurse := params[""] > depth
    SplitPath dir, dirName
    SetWorkingDir %dir%
    
    FileCreateDir %dest%
    subdirs := {}
    Loop Files, *.*, % recurse ? "FD" : ""
    {
        If (InStr(A_LoopFileAttrib, "D")) {
            subdirs[A_LoopFileName] := ""
        } Else If (A_LoopFileExt && params.HasKey(A_LoopFileExt)) {
            SplitPath A_LoopFileDir, leafdirName
            If (!(   params["\"].HasKey(leafdirName "\")
                  || params["\"].HasKey("\" A_LoopFileDir)) ) {
                SplitPath A_LoopFileName,,,,nameNoExt
                FileCreateShortcut %A_LoopFileLongPath%, % dest "\" LTrim(params[A_LoopFileExt] " " nameNoExt) ".lnk", %dir%\%A_LoopFileDir%,, (auto-created by %A_ScriptFullPath%)
            }
	}
    }
    
    If (recurse)
        For subdir in subdirs
            CreateDirShortcuts(dest "\" subdir, dir "\" subdir, params, ++depth)
    FileRemoveDir %dest%
}
