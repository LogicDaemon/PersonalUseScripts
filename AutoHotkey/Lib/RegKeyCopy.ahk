;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

RegKeyCopy(ByRef src, ByRef dst) {
    errors := 0
    If (!RegexMatch(src, "A)(?P<ComputerName>\\\\[^:\/]+:)?(?P<RootKey>[^\/:]+?)\\(?P<SubKey>.+)", srcReg))
        Throw Exception("reg root key not found in src",, src)
    
    ;MsgBox src: %src%`nsrcRegRootKey: %srcRegRootKey%`nsrcRegSubKey: %srcRegSubKey%
    srcSubkeyLen := StrLen(srcRegSubKey) + 1
    
    Loop Reg, %src%, R
    {
        If (srcRegSubKey == SubStr(A_LoopRegSubKey, 1, StrLen(srcRegSubKey)))
            dstRegSubkey := dst . SubStr(A_LoopRegSubKey, srcSubkeyLen)
        Else
            Throw Exception("Loop Reg subkey does not start with Src subkey",, A_LoopRegSubKey " ← " srcRegSubKey)
        RegRead v
        RegWrite %A_LoopRegType%, %dstRegSubkey%, %A_LoopRegName%, %v%
        errors += ErrorLevel
    }
    ErrorLevel := errors
}
