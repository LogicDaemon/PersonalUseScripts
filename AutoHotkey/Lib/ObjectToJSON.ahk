;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ObjectToJSON(objOrVal) {
    ; https://tools.ietf.org/html/rfc7159
    static screenChars := {Asc(""""): "", Asc("\"): ""}
    If (IsObject(objOrVal)) {
	txt := ""
	For i,v in objOrVal
	    txt .= ObjectToJSON(i) ": " . ObjectToJSON(v) ", "
	return "{" SubStr(txt, 1, -2) "}" ; -StrLen(", ") = -2 
    } Else {
        If objOrVal is Number
            return objOrVal
        Else {
            out := """"
            Loop Parse, objOrVal
            {
                charCode := Asc(A_LoopField) ; use Ord for Unicode supplementary character support, if needed 
                ; unescaped = %x20-21 / %x23-5B / %x5D-10FFFF
                If (screenChars.HasKey(charCode))
                    out .= "\" A_LoopField
                Else If (charCode == 0x20 || charCode == 0x21 || charCode >= 0x5D || (charCode >= 0x23 && charCode <= 0x5B))
                    out .= A_LoopField
                Else 
                    out .= Format("\x{:02x}", charCode)
            }
            out .= """"
            return out
        }
    }
}
