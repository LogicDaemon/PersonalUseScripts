;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (RegExMatch(A_LoopReadLine, "ASi)[\s()]*SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", m)) {
	    If (Trim(Trim(mName), """") = varname) {
		return Trim(Trim(mValue), """")
	    }
	}
    }
    Throw Exception("Var not found",, varname)
}
