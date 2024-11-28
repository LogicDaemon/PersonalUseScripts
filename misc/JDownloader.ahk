;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

args := ParseScriptCommandLine()

jdWinTitle=JDownloader 2 ahk_class SunAwtFrame
jdDir=%LocalAppData%\Programs\jdownloader
; SplitPath jdDir, OutFileName, OutDir ; , OutExtension, OutNameNoExt, OutDrive
ramDiskDir := "R:" RegExReplace(jdDir, "A)(?:\w:)",,, 1)
dropboxDir := GetDropboxDir(false)
RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
confBackupBaseDir = %dropboxDir%\config\@%hostname%\jdownloader
exe7z := find7zGUIorAny()

If (FileExist(jdDir "\cfg\uid")) {
    backupFailed := !BackupConfig()
} Else {
    For _, subDir in ["cfg", "logs", "tmp"] {
        FileCreateDir %ramDiskDir%\%subDir%
        If (!FileExist(jdDir "\" subDir "\."))
            RunWait %COMSPEC% /C "MKLINK /J "%jdDir%\%subDir%" "%ramDiskDir%\%subDir%""
    }
    RunWait "%exe7z%" x -aou -o"%jdDir%\cfg" -- "%confBackupBaseDir%\cfg.7z"
}
If (!backupFailed)
    SetTimer BackupConfig, 1800000 ; 30 minutes
Loop Files, %ProgramFiles%\Java\jre*, D
{
    jreDir := A_LoopFileFullPath
    break
}
jdWinHID := WinExist(jdWinTitle)
If (args || !jdWinHID) {
    TrayTip JDownloader starter, Starting JDownloader...
    Menu Tray, Tip, Starting JDownloader...
    Run "%jreDir%\bin\javaw.exe" -Xmx8G -jar "%jdDir%\JDownloader.jar" %args%, %jdDir%, jdPID
    Sleep 5000
} Else If (jdWinHID) {
    TrayTip JDownloader starter, JDownloader is already running
    Menu Tray, Tip, JDownloader is running already
    WinActivate
    Sleep 3000
}

Process_mode_background_begin()
Loop
{
    Menu Tray, Tip, JDownloader is running
    TrayTip
    While ( jdPID && WinExist("ahk_exe " jdPID)
         || jdWinHID && WinExist("ahk_id " jdWinHID) )
        WinWaitClose
    ; No window found, but that might be because an update is running
    jdPID:=""
    Menu Tray, Tip, JDownloader window is lost. Waiting in case it's an update.
    TrayTip JDownloader starter, JDownloader window is lost. Waiting in case it's an update.
    WinWait %jdWinTitle%,,60
    If (ErrorLevel)
        break
} Until !(jdWinHID := WinExist(jdWinTitle))

TrayTip JDownloader starter, No JDownloader window found after 60s. Probably it exited.
Menu Tray, Tip, JDownloader exited`, backing up config...
BackupConfig()
Process_mode_background_end()
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
    ; Need to only save the last of each bunch (which is older than 1 minute)
    ; zipMaxIndex := {prefix → maxSuffux}
    zipMaxIndex := {}, excludeFiles := []
    Loop Files, %jdDir%\cfg\*.zip, F
    {
        indexPos := RegExMatch(A_LoopFileName, "(\d+)\.zip$", m)
        If (!indexPos)
            Continue
        fileAge_s=
        fileAge_s -= A_LoopFileTimeModified, S
        prefix := SubStr(A_LoopFileName, 1, indexPos - 1)
        curIdx := m1 + 0
        prevIdx := zipMaxIndex[prefix]
        ; MsgBox m1=%m1%, prefix=%prefix%, curIdx=%curIdx%, prevIdx=%prevIdx%
        If (fileAge_s < 60 || m1 <= prevIdx) {
            excludeFiles.Push(prefix m1 ".zip")
            Continue
        }
        If (!prevIdx || m1 > prevIdx)
            zipMaxIndex[prefix] := m1
        If (prevIdx)
            excludeFiles.Push(prefix prevIdx ".zip")
    }

    excludeSwitches := ""
    For _, file in excludeFiles
        excludeSwitches .= "-x!""" file """ "
    TrayTip JDownloader starter, Backing up config...
    Menu Tray, Tip, Backing up config...
    RunWait "%exe7z%" a %excludeSwitches% %switches7z% -- "%confBackupBaseDir%\cfg.7z.tmp", %jdDir%\cfg, Min
    If (ErrorLevel) {
        TrayTip JDownloader starter, Config backup using 7-zip failed`, error %ErrorLevel%; starting backup using robocopy
        FileDelete %confBackupBaseDir%\cfg.7z.tmp
        RunWait robocopy.exe "%jdDir%\cfg\*.*" "%confBackupBaseDir%\" *.zip /ETA /MIR /ZB /DCOPY:DAT
        If (ErrorLevel) {
            TrayTip JDownloader starter, Config backup using robocopy failed`, error %ErrorLevel%
            Menu Tray, Tip, Config backup failed`, error %ErrorLevel%
            Run explorer.exe /open`,"%jdDir%\cfg"
            Run explorer.exe /open`,"%confBackupBaseDir%"
            Return False
        }
    } Else {
        FileMove %confBackupBaseDir%\cfg.7z.tmp, %confBackupBaseDir%\cfg.7z, 1
    }
    TrayTip JDownloader starter, Config is backed up
    Menu Tray, Tip, Config is backed up %A_HH%:%A_MM%
    Return True
}

Process_mode_background_begin() {
    DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00100000) ; PROCESS_MODE_BACKGROUND_BEGIN=0x00100000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
}

Process_mode_background_end() {
    DllCall("SetPriorityClass", "UInt", DllCall("GetCurrentProcess"), "UInt", 0x00200000) ; PROCESS_MODE_BACKGROUND_END=0x00200000 https://msdn.microsoft.com/en-us/library/ms686219.aspx
}

#include <ParseScriptCommandLine>
#include <find7zexe>
#include <GetDropboxDir>
