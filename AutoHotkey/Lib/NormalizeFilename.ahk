;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

; using hints suggested in https://www.autohotkey.com/board/topic/48523-convert-text-string-to-acceptable-filename-format/
NormalizeFilename(ByRef str) {
    local
    norm_name := RegexReplace(str, "[<>:""/\\|?*\x01-\x1F]", "_")
    If (norm_name ~= "^\.+$") ; Name is only dots
        return "_"
    return norm_name
}
