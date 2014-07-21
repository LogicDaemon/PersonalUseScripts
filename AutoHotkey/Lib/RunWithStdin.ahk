RunWithStdin(ByRef cmd, ByRef stdin) {
    Shell := ComObjCreate("WScript.Shell")
    Exec := Shell.Exec(cmd)
    Exec.StdIn.Write(stdin)
    Exec.StdIn.Close()

    return Exec
}
