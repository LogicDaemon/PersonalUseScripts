CmdlArgs(argsLimit := 0, switchRegex := "^[/-]") {
    local ; Force-local mode
    global A_Args
    switches := [], args := [], argc := 0
    
    For i, arg in A_Args {
        If (arg ~= switchRegex) {
            If (switches.HasKey(argc)) {
                If (!IsObject(switches[argc]))
                    switches[argc] := [switches[argc]]
                switches[argc].Push(arg)
            } Else {
                switches[argc] := arg
            }
        } Else {
            If (argsLimit && argc >= argsLimit)
                Throw Exception("Too many arguments",, arg)
            argc++
            args[argc] := arg
        }
    }
    If (switches.Length())
        args[0] := switches
    return args
}
