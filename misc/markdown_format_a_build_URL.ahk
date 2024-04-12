;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#Persistent
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; If RegexMatch("https://build.anymeeting.com/job/AM_Media/job/libs/job/DeepFilterNet/64/"
;             , "O)https?://build\.anymeeting\.com(?P<JobPath>(/job/[^/ ]+)+)((?P<BuildNum>/\w+)/)?"
;             , m)
;     MsgBox % m.BuildNum

OnClipboardChange(Func("clipboardChange"))

ClipboardChange(dataType) {
    Static ignoreChanges
    ; dataType variants:
    ; •0 = Clipboard is now empty.
    ; •1 = Clipboard contains something that can be expressed as text (this includes files copied from an Explorer window).
    ; •2 = Clipboard contains something entirely non-text such as a picture.
    if (ignoreChanges || dataType != 1)
        return

    ClipWait 0
    cb := ConvertBuildURLsToMarkdown(Clipboard)
    if (cb) {
        ignoreChanges := True
        Clipboard := cb
        ToolTip Converted to markdown: %cb%
        ClipWait 0
        Sleep 100
        ignoreChanges := False
        ToolTip
    }
}

ConvertBuildURLsToMarkdown(ByRef text) {
    ; https://build.anymeeting.com/job/AM_Media/job/libs/job/DeepFilterNet/64/
    ; ->
    ; [`AM_Media/libs/DeepFilterNet/64`](https://build.anymeeting.com/job/AM_Media/job/libs/job/DeepFilterNet/64/)
    out := ""
    lastOffset := 1
    maxOffset := StrLen(text)
    While lastOffset < maxOffset
            && RegExMatch(text
                        , "O)https?://build\.anymeeting\.com(?P<JobPath>(/job/[^/ ]+)+)(?P<BuildNum>/\w+)?/?"
                        , m
                        , lastOffset) {
        shortenedJobPath := Trim(StrReplace(m.JobPath, "/job/", "/"), "/")
        out .= SubStr(text, lastOffset, m.Pos(0) - lastOffset)
            . "[" shortenedJobPath m.BuildNum "](" m[0] ")"
        lastOffset := m.Pos(0) + m.Len(0)
    }
    return out . SubStr(text, lastOffset)
}
