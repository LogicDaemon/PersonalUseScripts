;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; No idea if it works. Just a try
Run "%A_ProgramFiles%\Acer\PredatorSense Service\PSAgent.exe",,, procPid
Process Priority, %procPid%, Low
Run %SystemRoot%\System32\net.exe start PSSvc,, Hide
Run %SystemRoot%\System32\net.exe start XTU3SERVICE,, Hide
;just opens up a Run explorer.exe shell:appsFolder\AcerIncorporated.PredatorSenseV30_3.0.3152.0_x64__48frkmn4z8aw4!CentenialConvert
Run "%A_ScriptDir%\helper_shortcuts\PredatorSense_UWP_app.lnk"
;C:\Program Files\WindowsApps\AcerIncorporated.PredatorSenseV30_3.0.3152.0_x64__48frkmn4z8aw4\Win32\PredatorSense.exe
GroupAdd ps, ahk_exe PSLoading.exe
GroupAdd ps, ahk_exe PredatorSense.exe

While True {
    WinWait ahk_group ps,,3
    If (ErrorLevel)
        break

    If (WinExist("ahk_exe PSLoading.exe"))
        WinHide
}

;WinClose
