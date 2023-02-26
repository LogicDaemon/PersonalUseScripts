;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

; using hints suggested in https://www.autohotkey.com/board/topic/48523-convert-text-string-to-acceptable-filename-format/
NormalizeFilename(ByRef str) {
    local
    norm_name := RegexReplace(str, "[<>:""/\\|?*\x01-\x1F]", "_")
    If (norm_name ~= "^\.+$") ; Name is only dots
        return "_"
    return norm_name
}
