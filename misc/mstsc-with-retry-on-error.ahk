;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

rdpDirs := []
Try rdpDirs.Push(GetDropboxDir())
rdpDirs.Push(A_Desktop, A_MyDocuments)

cmdLineArgs := ParseScriptCommandLine(fullCmdLine := -1)
If (cmdLineArgs[-2] == "")
    Throw Exception("First arg is empty",,"First arg should be name-or-path to RDP file, or a host name")
rdpNameOrPath := Trim(cmdLineArgs[-2], """")

If (FileExist(rdpNameOrPath)) {
    prefixArgs := cmdLineArgs[-2]
} Else {
    For i, rdpDir in rdpDirs {
        If (FileExist(rdpPath := rdpDir "\" rdpNameOrPath)) {
            prefixArgs = /w:1920 /h:1080 /admin /v "%rdpPath%"
            break
        }
    }
    If (!prefixArgs)
        prefixArgs := "/w:1920 /h:1080 /admin /v " cmdLineArgs[-2]
}
Loop
{
    Run %SystemRoot%\System32\mstsc.exe %prefixArgs% %fullCmdLine%,%A_Temp%,,rPID
    WinWait Remote Desktop Connection ahk_class #32770 ahk_exe mstsc.exe ahk_pid %rPID%,&Help,5 ; other text: OK
    If (ErrorLevel)
        break
    ControlClick OK
    Process WaitClose, %rPID%
}
