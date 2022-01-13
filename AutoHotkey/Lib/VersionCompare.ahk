;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

; compare versions by components
; VersionCompare(v1, v2, false) returns (v1 > v2)
; VersionCompare(v1, v2, true) returns (v1 >= v2)
; VersionCompare(v1, v2, rval) returns (v1 == v2 ? rval : v1 > v2)
VersionCompare(verTest, verMin, ByRef rvalIfVersionEqual) {
    local
    If (!IsObject(verTest))
        verTest := VersionStringToArray(verTest)
    If (!IsObject(verMin))
        verMin := VersionStringToArray(verMin)
    For i, min in verMin {
        test := verTest[i]
        If (test < min)
            return false
        Else If (test > min)
            return true
    }
    
    ;equal
    return rvalIfVersionEqual
}

#include <VersionStringToArray>
