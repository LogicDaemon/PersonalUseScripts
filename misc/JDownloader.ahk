;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

args := ParseScriptCommandLine()

If (!args && WinExist("JDownloader 2 ahk_class SunAwtFrame")) {
    WinActivate
    ExitApp
}

jdDir=%LocalAppData%\Programs\jdownloader
; SplitPath jdDir, OutFileName, OutDir ; , OutExtension, OutNameNoExt, OutDrive
ramDiskDir := "R:" RegExReplace(jdDir, "A)(?:\w:)",,, 1)
dropboxDir := GetDropboxDir(false)
RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
confBackupBaseDir = %dropboxDir%\config\@%hostname%\jdownloader
exe7z := find7zGUIorAny()

If (FileExist(jdDir "\cfg\uid")) {
    BackupConfig()
} Else {
    For _, subDir in ["cfg", "logs", "tmp"] {
        FileCreateDir %ramDiskDir%\%subDir%
        If (!FileExist(jdDir "\" subDir "\."))
            RunWait %COMSPEC% /C "MKLINK /J "%jdDir%\%subDir%" "%ramDiskDir%\%subDir%""
    }
    RunWait "%exe7z%" x -aou -o"%jdDir%\cfg" -- "%confBackupBaseDir%\cfg.7z"
}
SetTimer BackupConfig, 1800000 ; 30 minutes
Loop Files, %ProgramFiles%\Java\jre*, D
{
    jreDir := A_LoopFileFullPath
    break
}
Menu Tray, Tip, JDownloader was started
RunWait "%jreDir%\bin\javaw.exe" -Xmx8G -jar "%jdDir%\JDownloader.jar" %args%, %jdDir%
Menu Tray, Tip, JDownloader exited`, backing up config...
BackupConfig()
Exit

BackupConfig() {
    local
    global exe7z, jdDir, confBackupBaseDir
    switches7z = -mx=9 -m0=BCJ2 -m1=LZMA2:a=2:fb=273 -m2=LZMA2:d22 -m3=LZMA2:d22 -mb0:1 -mb0s1:2 -mb0s2:3 -mqs
    
    ;The config directory contains archives of links, which are named like this:
    ;downloadList1270.zip
    ;downloadList1271.zip
    ;downloadList1272.zip
    ;downloadList1273.zip
    ;downloadList1274.zip
    ;downloadList1275.zip
    ;linkcollector987.zip
    ;linkcollector988.zip
    ;linkcollector989.zip
    ;linkcollector990.zip
    ;linkcollector991.zip
    ;linkcollector992.zip
    ; Need to only keep the last of each bunch
    ; zipMaxIndex := {prefix → maxSuffux}
    zipMaxIndex := {}, excludeFiles := []
    Loop Files, %jdDir%\cfg\*.zip, F
    {
        suffixStart := RegExMatch(A_LoopFileName, "(\d+)\.zip$", m)
        If (!suffixStart)
            Continue
        prefix := SubStr(A_LoopFileName, 1, suffixStart - 1)
        curIdx := m1 + 0
        prevIdx := zipMaxIndex[prefix]
        ; MsgBox m1=%m1%, prefix=%prefix%, curIdx=%curIdx%, prevIdx=%prevIdx%
        If (prevIdx && m1 > prevIdx) {
            excludeFiles.Push(prefix prevIdx ".zip")
        }
        zipMaxIndex[prefix] := m1
    }

    excludeSwitches := ""
    For _, file in excludeFiles
        excludeSwitches .= "-x!""" file """ "
    RunWait "%exe7z%" a %excludeSwitches% %switches7z% -- "%confBackupBaseDir%\cfg.7z.tmp", %jdDir%\cfg, Min
    If (ErrorLevel) {
        FileDelete %confBackupBaseDir%\cfg.7z.tmp
        RunWait robocopy.exe "%jdDir%\cfg\*.*" "%confBackupBaseDir%\" *.zip /ETA /MIR /ZB /DCOPY:DAT
    } Else {
        FileMove %confBackupBaseDir%\cfg.7z.tmp, %confBackupBaseDir%\cfg.7z, 1
    }
    TrayTip JDownloader, Config is backed up
}

#include <ParseScriptCommandLine>
#include <find7zexe>
#include <GetDropboxDir>
