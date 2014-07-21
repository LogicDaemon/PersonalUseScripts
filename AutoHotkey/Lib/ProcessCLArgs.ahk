#NoEnv

ProcessCLArgs(switches, switchTypes := 0) {
    ; switches: {name: [commandline-switch-1, commandline-switch-2, …], …}
    ;   example: {"R": ["R", "Read-only", "RO"]} ; to make /R, -Read-Only and +RO map to same "R" key in output object and help
    ; switchTypes: see below
    
    If switchTypes is Integer
        switchTypes := { 0: {        "/": true, "-": true}
                       , 1: {"": "", "/": true, "-": true}
                       , 2: {"": "", "/": true, "-": false, "+": true}
                       , 3: {"": "ProcessCLArgs_FileOpenRead", "/": ""}}[switchTypes]
    allowUnflaggedArgs := switchTypes.HasKey("")
    out := allowUnflaggedArgs ? {"": []} : {} ; if unflagged args allowed, we might need an array to push them in

    clTextToConfigName := {}
    For name, clSwitchText in switches {
        If (IsObject(clSwitchText)) {
            For i, clSwitchText in clSwitchText
                clTextToConfigName[clSwitchText] := name    
        } Else {
            clTextToConfigName[clSwitchText] := name    
        }
    }
    
    For i, arg in A_Args {
        swTypeFound := false
        For flag, swType in switchTypes {
            If (StrLen(flag) && SubStr(arg, 1, StrLen(flag)) = flag) {
                ProcessCLArgs_ProcessSwitch(clTextToConfigName, SubStr(arg, StrLen(flag)+1), out, swType, arg, flag, i)
                , swTypeFound := true
                break
            }
        }
        If (swTypeFound)
            continue
        If (allowUnflaggedArgs) { ; 
            flag := ""
            , swType := switchTypes[""]
            , ProcessCLArgs_ProcessSwitch(clTextToConfigName, arg, out, swType, arg, flag, i)
        } Else {
            Throw Exception("Naked command line arguments not supported",, arg)
        }
    }
    return out
}

ProcessCLArgs_ProcessSwitch(clTextToConfigName, clswitchName, out, args*) {
    If (!clTextToConfigName.HasKey(clswitchName))
        Throw Exception("Unknown switch",, clswitchName)
    out[clTextToConfigName[clswitchName]] := ProcessCLArgs_GetSwitchValue(args*)
}

ProcessCLArgs_GetSwitchValue(swType, fnargs*) {
    If (swType == "")
        return swType
    If (!IsObject(swType)) {
        If (IsFunc(swType))
            swType := Func(swType)
        Else
            return swType
    }
    return swType.Call(fnargs*)
}

ProcessCLArgs_FileOpenRead(ByRef name) {
    return FileOpen(name, "r")
}
