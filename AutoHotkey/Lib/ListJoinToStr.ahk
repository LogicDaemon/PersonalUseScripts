ListJoinToStr(list, sep := "") {
    Local
    If (list.Length() = 0)
        return ""
    If (list.Length() = 1)
        return list[1]
    result := list[1]
    For index, item in list {
        If (index > 1)
            result .= sep . item
    }
    return result
}
