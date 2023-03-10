;Expand env %vars% in string, converting %% (double percent sequences) to %
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

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
