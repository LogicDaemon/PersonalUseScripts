#NoEnv

For i, procName in A_Args
    Process Wait, %procName%

Sleep 5000

For i, procName in A_Args
    For pid in ProcessList(procName)
        Process Priority, %pid%, N
