GetEncoding() {
    local
    static chars
    If (IsSet(chars))
        return chars
    EnvGet LocalAppData, LOCALAPPDATA
    encFile := LocalAppData "\_sec\encoding.txt"
    ; for example,
    ; " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~⌂░▒▓│┤╡╢╖╕╣║╗╝╜╛┐╢┴┬╣─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀Ўў°∙·√№¤■ "
    f := FileOpen(encFile, "r", "cp866")
    If (!f)
        Throw Exception("Failed to open encoding file", , encFile)
    chars := f.Read()
    f.Close()
    If (!chars)
        Throw Exception("Failed to read encoding file", , LocalAppData "\_sec\encoding.txt")
    charsUsed := {}
    anyTwo := false
    Loop Parse, chars
    {
        code := Asc(A_LoopField)
        If (charsUsed.HasKey(code))
            Throw Exception("Character set contains a duplicate", , """" A_LoopField """ (code " code ")")
        charsUsed[code] := ""
    }
    Return chars
}

CharsPerNumber(max, min := 0) {
    ; Return the number of characters required to encode a number in the current encoding
    local
    static chars := GetEncoding()
    static numChars := StrLen(chars)
    Return -(Ln(max-min+1) // -Ln(numChars)) | 0
}

NumToChars(n, max := "", min := 0) {
    ; Convert a number to a string consisting of chars from the encoding file
    ; max - the maximum number to be encoded. Used to make the encoded string a fixed length.
    ; min - the minimum number to be encoded.
    local
    static chars := GetEncoding()
    static numChars := StrLen(chars)

    If (n < min || max && n > (max))
        Throw Exception("Number exceeds maximum", , n)

    encoded := ""
    r := n - min
    Loop
    {
        rem := Mod(r, numChars)
        encoded := SubStr(chars, rem + 1, 1) . encoded
        r //= numChars
    } Until !r
    If (max) {
        ; . If either of the inputs is in floating point format,
        ; floating point division is performed and the result is truncated
        ; to the nearest integer to the left.
        ; For example, 5//3.0 is 1.0 and 5.0//-3 is -2.0.
        padLen := CharsPerNumber(max, min) - StrLen(encoded)
        fillerChar := SubStr(chars, 1, 1)
        While (padLen-- > 0)
            encoded := fillerChar . encoded
    }
    Return encoded
}

CharsToNum(s, min := 0) {
    ; Convert a string consisting of chars from the encoding file to a number
    local
    static chars := GetEncoding()
    static numChars := StrLen(chars)
    n := 0
    Loop Parse, s
    {
        pos := InStr(chars, A_LoopField, 1)
        If (!pos)
            Throw Exception("Character not found in encoding", , """" A_LoopField """")
        n := n * numChars + pos - 1
    }
    return n + min
}

; MsgBox % -Round(Ln(100) // -Ln(99))
; MsgBox % -(Ln(100) // -Ln(99)) | 0
; MsgBox % CharsToNum(NumToChars(123456, 999999))
; MsgBox % CharsToNum(NumToChars(123456, 999999, -999999), -999999)
; MsgBox % NumToChars(123456, 999999) "`n" CharsToNum(" %T@")
; MsgBox % NumToChars(123456, 999999999) "`n" CharsToNum(" %T@")
; MsgBox % CharsToNum(NumToChars(123456))
; MsgBox % CharsToNum(NumToChars(412886))
; MsgBox % CharsToNum(NumToChars(412918))
