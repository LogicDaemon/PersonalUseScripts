ActivateOrRun(title, text="", cmd="", dir="") {
    If (WinExist(title, text)) {
        If (WinActive())
                WinActivateBottom %title%, %text%
        Else
                WinActivate
    } else if (cmd != "") {
        Run %cmd%, %dir% 
    }
    return ErrorLevel
}
