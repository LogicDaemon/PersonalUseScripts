;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

FormatTimeSoon(amount, unit := "Minutes", format := "Time") {
    local
    timeoutMsgVal := ""
    timeoutMsgVal += %amount%, %unit%
    FormatTime timeoutMsgText, %timeoutMsgVal%, %format%
    return timeoutMsgText
}
