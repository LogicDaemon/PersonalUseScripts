;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}
