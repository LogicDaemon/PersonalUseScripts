#NoEnv
FileEncoding UTF-8

prepend_text(ByRef fname, ByRef moreData := "") {
    prepend=
    While (!IsObject(wlfile := FileOpen(fname, "rw-w"))) {
        Random, delay, 1, 300
        Sleep %delay%
    }
    content := wlfile.Read()
    FormatTime now,, yyyy-MM-dd H:mm
    If (moreData) {
        prepend := moreData
    } Else If (clipbrd := Clipboard) {
        clipLines := {}
        Loop Parse, clipbrd, `n, `r
            clipLines[Trim(A_LoopField)] := 1
        Loop Parse, content, `n, `r
            If (clipLines.HasKey(trim_a_lf := Trim(A_LoopField)))
                clipLines[trim_a_lf] := "", found=1
        If (!found) {
            prepend := clipbrd
        } Else {
            Loop Parse, clipbrd, `n, `r
            {
                If (!clipLines.HasKey(Trim(A_LoopField))) {
                    prepend .= A_LoopField "`n"
                }
            }
        }
    }
    If (prepend) {
        Try FileDelete %fname%.bak
        FileAppend %content%, %fname%.bak
        wlfile.Seek(0)
        wlFile.WriteLine(now)
        wlFile.WriteLine(prepend "`n")
        wlFile.Write(content)
        wlFile.Close()
    }
}

If (A_TimeIdlePhysical < 60*60*1000) {
    If (A_Args.Length())
        For i, v in A_Args
            data .= ( i>1 ? " " : "" ) . v
    Try {
        prepend_text(A_MyDocuments "\worklog.md", data)
    } Catch e {
        Throw e
    }
}
