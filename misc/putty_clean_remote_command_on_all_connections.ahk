#NoEnv

regKey = HKCU
subkeyBase = SOFTWARE\SimonTatham\PuTTY\Sessions

sessions := []
Loop Reg, %regKey%\%subkeyBase%\, K
    sessions.Push(A_LoopRegName)

delCommands := { "/bin/sh -c 'tmux -2u new-session -As aderbenev || /usr/bin/screen -xRR || bash -l'": ""
               , "/usr/bin/sh -c 'tmux -2u new-session -As aderbenev || /usr/bin/screen -xRR || bash -l'": ""
               , "screen -xRR": ""
               , "/usr/bin/screen -xRR": "" }

For i, session in sessions {
    subKey = %subkeyBase%\%session%
    RegRead remoteCommand, %regKey%, %subKey%, RemoteCommand
    If (remoteCommand)
        If (delCommands.HasKey(remoteCommand))
            RegDelete %regKey%, %subKey%, RemoteCommand
        Else
            MsgBox %session%: %remoteCommand%
}
