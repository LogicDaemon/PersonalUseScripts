;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

StartsWith(ByRef long, ByRef short) {
    return short = SubStr(long, 1, StrLen(short))
}
