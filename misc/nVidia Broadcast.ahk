;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

nvbVariants := { A_ProgramFiles "\NVIDIA Corporation\NVIDIA Broadcast": ["NVIDIA Broadcast.exe"
                                                                        , "--process-start-args ""--launch-hidden"""
                                                                        , Func("CloseWindow")]
               , A_ProgramFiles "\NVIDIA Corporation\NVIDIA Broadcast": ["NVIDIA Broadcast UI.exe"
                                                                        , "-minimized"
                                                                        , Func("DismissUpdate")]}

For dirName, params in nvbVariants {
    fileName := params[1]
    If (!FileExist(dirName "\" fileName))
        Continue
    Process Exist, %fileName%
    If (!ErrorLevel) {
        args := params[2]
        Run "%fileName%" %args%, %dirName%,, nbvPID
    }
    func := params[3]
    If (func) {
        func.Call(nbvPID)
    }
}
ExitApp

CloseWindow(nbvPID) {
    If (!nbvPID)
        Return
    WinWait ahk_pid %nbvPID%,, 60
    If (ErrorLevel)
        Return
    WinGet r, MinMax
    If (r != -1)
        PostMessage 0x0112, 0xF060  ; 0x0112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
}

DismissUpdate(nvbPID) {
    If (nvdPID)
        titleSuffix = ahk_pid %nvbPID%
    Else
        titleSuffix = ahk_exe NVIDIA Broadcast UI.exe
    WinWait %titleSuffix%,REMIND ME LATER, 300
    If (ErrorLevel)
        Return
    ControlClick REMIND ME LATER
}
