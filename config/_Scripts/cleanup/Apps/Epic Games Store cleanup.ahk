;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RegRead installLocation, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{FAC47927-1A6A-4C6E-AD7D-E9756794A4BC}, InstallLocation

Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData, K
{
    Loop Reg, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%\Components, K
    {
        skip := False
        kv_count := 0
        Loop Reg, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%
        {
            kv_count++
            If (kv_count > 1) {
                skip := True
                break
            }
            RegRead data
            If (!(InStr(data, installLocation, True))) {
                skip := True
                break
            }
        }
        If (skip)
            Continue
        Loop Reg, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, K
        {
            kv_count++
        }
        If (kv_count > 1)
            Continue
        Run regjump.exe "%A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%"
        RegDelete, %A_LoopRegKey%, %A_LoopRegSubkey%
    }
}
Loop Reg, HKEY_CURRENT_USER\Software\Khronos\Vulkan\ImplicitLayers
{
    If (InStr(A_LoopRegName, installLocation, True))
        RegDelete, %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%
}

RegRead appDataPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Epic Games\EpicGamesLauncher, AppDataPath
If (appDataPath)
    Run explorer.exe /explore`,"%appDataPath%"

MsgBox Deleting settings from the registry
RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\WOW6432Node\EpicGames
RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\WOW6432Node\Epic Games

