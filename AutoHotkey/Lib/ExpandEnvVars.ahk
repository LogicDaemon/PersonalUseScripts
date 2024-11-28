;Expand env %vars% in string, converting %% (double percent sequences) to %
;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ExpandEnvVars(ByRef string) {
    local ; Force-local mode
    PrevPctChr := 1, LastPctChr := 0, VarnameJustFound := false, output:=""

    While ( LastPctChr:=InStr(string, "%", true, PrevPctChr) ) {
        currFragment := SubStr(string,PrevPctChr,LastPctChr-PrevPctChr) ; plain text or %var name%
	If (VarnameJustFound) {
	    EnvGet CurrEnvVar,% currFragment
	    output .= CurrEnvVar
	    VarnameJustFound:=false
	} else {
	    output .= currFragment
	    If (SubStr(string, LastPctChr+1, 1) == "%") ;double-percent %% skipped ouside of varname
		output .= "%", LastPctChr++
	    else
		VarnameJustFound := true
	}
	PrevPctChr := LastPctChr+1
    }

    If (VarnameJustFound) ; non-closed varname
	Throw Exception("Var name not closed",, SubStr(string,PrevPctChr))
	
    return output . SubStr(string,PrevPctChr)
}
