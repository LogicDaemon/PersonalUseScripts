; RegWriteUserEnv returns true if value is updated (call EnvUpdate then)
; oldValue gets old value. Other args as their name says.
; as with SET, pass "" as Value to delete the var
RegWriteUserEnv(ByRef VarName, ByRef Value, OnlyReplaceIfEmpty := false, ByRef oldValue := "") {
    RegRead oldValue, HKEY_CURRENT_USER\Environment, %VarName%
    If (onlyReplaceIfEmpty && oldValue)
        return false
    If (oldValue==Value) ; «!=» <> «!(==)». «==» is always case-sensitive, unlike «=» and «!=»
        return false
    If (Value=="")
        RegDelete HKEY_CURRENT_USER\Environment, %VarName%
    Else
        RegWrite REG_EXPAND_SZ, HKEY_CURRENT_USER\Environment, %VarName%, %Value%
    return !ErrorLevel
}
