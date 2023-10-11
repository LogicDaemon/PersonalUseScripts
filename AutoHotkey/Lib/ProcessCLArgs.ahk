#NoEnv

ProcessCLArgs(switches, switchTypes := 0, keepUnknownArgs := false) {
    ; switches: {name: [commandline-switch-1, commandline-switch-2, …], …}
    ;   example: {"R": ["R", "Read-only", "RO"]} ; to make /R, -Read-Only and +RO map to same "R" key in output object and help
    ; switchTypes: int or a {key: action} dict.
    ;   For ints, look below;
    ;   In the dictionary,
    ;     key is a string prefix of the argument which determines action taken;
    ;     action is used to determine the value in the config[name]:
    ;       if action is a function name, its return value is used;
    ;       otherwise, the value is used in config directly.
    
    If switchTypes is Integer
        switchTypes := { 0: {        "/": true, "-": true}
                       , 1: {"": "", "/": true, "-": true}
                       , 2: {"": "", "/": true, "-": false, "+": true}
                       , 3: {"": "ProcessCLArgs_FileOpenRead", "/": ""}}[switchTypes]
    allowUnflaggedArgs := switchTypes.HasKey("") || keepUnknownArgs
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
    
    flagLengths := {}
    For flag in switchTypes {
        flagLength := StrLen(flag)
        If (flagLength)
            flagLengths[flagLength] := ""
    }
    
    For i, arg in A_Args {
        swType := ""
        For flagLength in flagLengths {
            flag := SubStr(arg, 1, flagLength)
            If (switchTypes.HasKey(flag)) {
                swType := switchTypes[flag]
                If (ProcessCLArgs_ProcessSwitch(clTextToConfigName
                                                , SubStr(arg, StrLen(flag)+1)
                                                , out, swType, arg, flag, i)) {
                    If (keepUnknownArgs) {
                        out[""].Push(arg)
                    } Else {
                        Throw Exception("Unknown switch",, clSwitchName)
                    }
                }
                break
            }
        }
        If (swType)
            continue
        If (allowUnflaggedArgs) {
            flag := ""
            , swType := switchTypes[""]
            If (ProcessCLArgs_ProcessSwitch(clTextToConfigName
                                            , arg, out, swType, arg, flag, i)) {
                If (keepUnknownArgs) {
                    out[""].Push(arg)
                } Else {
                    Throw Exception("Unknown switch",, clSwitchName)
                }
            }
        } Else {
            Throw Exception("Naked command line arguments not supported",, arg)
        }
    }
    return out
}

ProcessCLArgs_ProcessSwitch(ByRef clTextToConfigName, ByRef clSwitchName, ByRef out, args*) {
    ; returned True means unknown switch name
    If (!clTextToConfigName.HasKey(clSwitchName))
        Return True
    out[clTextToConfigName[clSwitchName]] := ProcessCLArgs_GetSwitchValue(args*)
    Return False
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
