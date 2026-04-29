;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; %LocalAppData%\Programs\bin
; %LocalAppData%\Programs\UnxUtils
; %LocalAppData%\Programs\scoop\apps\git\current\usr\bin
; C:\Users\username\AppData\Local\Programs\scoop\apps\git\current\cmd
; C:\Users\username\AppData\Local\Programs\scoop\persist\bun\bin
; C:\Users\username\AppData\Local\Programs\scoop\apps\python\current\Scripts
; C:\Users\username\AppData\Local\Programs\scoop\apps\python\current
; C:\Users\username\go\bin
; %LocalAppData%\Scripts
; C:\Users\username\AppData\Local\Programs\scoop\shims
; %LocalAppData%\Programs\msys64\usr\bin ; must be after python, otherwise msys64's python will be used, while pip will be from scoop
; %USERPROFILE%\AppData\Local\Microsoft\WindowsApps

RegRead Path, HKEY_CURRENT_USER, Environment, Path
out_path_items_order := [ "Programs\bin"
                        , "UnxUtils"
                        , "git\current\usr\bin"
                        , "git\current\cmd"
                        , "scoop\shims"
                        , ""
                        , "msys64\usr\bin"
                        , "Microsoft\WindowsApps" ]
For i, suffix in out_path_items_order
    If (!suffix)
        unclassified_index := i

out_classified := {}
Loop Parse, Path, `;
{
    For i, suffix in out_path_items_order
    {
        tgt_idx := unclassified_index
        ;MsgBox % suffix "`n" SubStr(A_LoopField, 1-StrLen(suffix))
        If (suffix && SubStr(A_LoopField, 1-StrLen(suffix)) = suffix) {
            tgt_idx := i
            break
        }
    }
    If (!out_classified[tgt_idx]) {
        out_classified[tgt_idx] := [A_LoopField]
    } Else {
        out_classified[tgt_idx].Push(A_LoopField)
    }
}

;MsgBox % ObjectToText(out_classified)
out_path := ""
For i, items in out_classified
    For j, item in items
        out_path .= item ";"
out_path := SubStr(out_path, 1, -1) ; Remove trailing semicolon
If (out_path == Path) {
    MsgBox, No changes needed. The Path variable is already in the desired order.
    ExitApp
}
MsgBox 4, Path updated, % "Old Path:`n" Path "`nNew Path:`n" out_path
IfMsgBox Yes
    RegWrite REG_EXPAND_SZ, HKEY_CURRENT_USER, Environment, Path, %out_path%
