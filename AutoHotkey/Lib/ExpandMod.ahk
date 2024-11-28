;Expand %vars% in string, converting %% (double percent sequences) to %
; tries to find var name in:
; 1. substVars:
;   - { varname: value             ; direct substitution
;   - , varname: function_object } ; substitutes to return value of the function
; 2. EnvVars
; 3. script variables
; 4. substVars[""]
;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

ExpandMod(ByRef string, substVars := 0) {
    global
    local PrevPctChr:=1, LastPctChr:=0, VarnameJustFound:=false, currFragment, currEnvVar, output:=""
    ; pretext %var% posttext
    ;             ^ LastPctChr
    ;          ^ PrevPctChr (prev iteration of LastPctChr + 1)
    While ( LastPctChr:=InStr(string, "%", true, PrevPctChr) ) {
        currFragment := SubStr(string,PrevPctChr,LastPctChr-PrevPctChr) ; plain text or %var name%
	If (VarnameJustFound) {
	    VarnameJustFound:=false
            If (IsFunc(substVars)) {
                substVars.Call(currFragment)
            } Else {
                If (substVars.HasKey(currFragment)) {
                    currEnvVar := substVars[currFragment]
                    If (IsObject(currEnvVar))
                        currEnvVar := Func(currEnvVar).Call(string, PrevPctChr)
                } Else {
                    EnvGet currEnvVar,%currFragment%
                    If (!currEnvVar) {
                        Try {
                            currEnvVar := %currFragment%
                        } Catch {
                            currEnvVar := substVars[""]
                        }
                    }
                }
            }
            output .= currEnvVar
	} else {
	    output .= currFragment
	    If (SubStr(string, LastPctChr+1, 1) == "%") ;double-percent %% skipped ouside of varname
		output .= "%", LastPctChr++
	    else
		VarnameJustFound := true
	}
	PrevPctChr := LastPctChr+1
    }
    
    If (VarnameJustFound) ; non-closed "%varname"
	Throw Exception("Var name not closed",, SubStr(string,PrevPctChr))
    
    return output . SubStr(string,PrevPctChr)
}
