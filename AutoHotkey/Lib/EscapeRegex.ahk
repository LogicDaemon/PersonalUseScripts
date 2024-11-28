;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

EscapeRegex(ByRef t) {
    ; via https://stackoverflow.com/a/25837411
    Return RegexReplace(t, "[\-\[\]{}()*+?.,\\\^$|#\s]", "\$0")
}
