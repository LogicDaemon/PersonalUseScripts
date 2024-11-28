;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

MoveTaskbar()

MoveTaskbar() {
    local
    WinGetPos winX, winY, winW, winH, ahk_class Shell_TrayWnd ahk_exe Explorer.EXE

    monCentralPoints := []
    Loop {
        SysGet MonDim, Monitor, %A_Index%
        If (!(MonDimLeft || MonDimRight || MonDimTop || MonDimBottom))
            Break
        If ( MonDimLeft <= winX && MonDimRight >= winX && MonDimTop <= winY && MonDimBottom >= winY )
            curMon := A_Index
        monCentralPoints[A_Index] := [MonDimLeft + (MonDimRight - MonDimLeft)/2, MonDimTop + (MonDimBottom - MonDimTop)/2]
        , monCount := A_Index
        , monMaxWidth := Max(monMaxWidth, MonDimRight - MonDimLeft)
        , monMaxHeight := Max(monMaxHeight, MonDimBottom - MonDimTop)
    }
    newMon := curMon < monCount ? curMon + 1 : 1

    SysGet MonWA, MonitorWorkArea, %newMon%
    newW := winW
    newH := MonWAHeight
    newX := MonWARight - newW
    newY := MonWATop

    WinMove ahk_class Shell_TrayWnd ahk_exe Explorer.EXE,, newX, newY, newW, newH
}
