; Total Commander wrapper for zpaq.exe. Runs zpaq.exe for each file in the list,
; prefixing long paths with \\?\ and using relative paths to source files.

;command line: zpaq.ahk <cmd> <utf8 files list> <destination>
; <cmd>	: a,l or x
; <utf8 files list> : path to UTF-8 text file which contains newline-delimeted list files to be processed by zpaq
; <destination> : path to destination folder for a and x commands (in case of l, it is ignored)

;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#SingleInstance off

FileEncoding UTF-16

Global Path,LocalAppData,SystemDrive
EnvGet Path,PATH
EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemDrive,SYSTEMDRIVE

zpaqexe := """" Findzpaqexe() """"

If (FileExist(sevenMaxExe := LocalAppData "\Programs\7-max\7maxc.exe"))
    zpaqexe = "%sevenMaxExe%" -t %zpaqexe%

Try {
    teeexe := FindTeeExe()
    ; this way redirection works but records overlap : redirCmd = 2>&1 | "%teeexe%" -a
    redirCmd = | "%teeexe%" -a
    cmdSuffix = || PAUSE
} Catch {
    redirCmd := ">>"
    cmdSuffix := ""
}
cmd=%1%

If (cmd="l")
    tmpListFile=%A_Temp%\%A_ScriptName%-list.%A_Now%.txt

Loop Read, %2%
{
    SplitPath A_LoopReadLine, lastListedFileName, lastListedDir, OutExtension, lastListedNameNoExt, OutDrive
    If (cmd="x") {
        WaitCPUIdle (zpaqPID, 1, 30, 1)
        Run %comspec% /U /C "CHCP 65001 & %zpaqexe% x "%A_LoopReadLine%" -to "%3%%lastListedNameNoExt%" 2>>"%3%%lastListedNameNoExt%.errors.log" %redirCmd% "%3%%lastListedNameNoExt%.log" %cmdSuffix%",,Min, zpaqPID
    } Else If (cmd="l") {
        RunWait %comspec% /U /C "CHCP 65001 & %zpaqexe% l "%A_LoopReadLine%" -all 2>>&1 %redirCmd% "%tmpListFile%" %cmdSuffix%",,Min
    } Else If (cmd="a") {
        If (A_Index==1) {
            files := Object()
            curBasePath := lastListedDir
        } Else {
            curBasePath := CommonPath(curBasePath, lastListedDir)
        }
        files.Push(A_LoopReadLine)
        If (!longPaths) {
            ; even with START "" /D "\\?\%curBasePath%" and relative paths to source files (or *),
            ; zpaq still cannot pack if full path length is 260 or more chars (despite the relative path is shorter).
            ; If such paths found, fall back to \\?\ prefixes.
            longPaths := LongPathsInDir(A_LoopReadLine)
        }
    } Else {
        MsgBox Command unsupported: %cmd%
        ExitApp
    }
}

If (cmd="l") {
    Run "%tmpListFile%"
} Else If (cmd="a") {
    If (curBasePath) {
        SplitPath curBasePath, arcName
    } Else {
        arcName:=A_Now
    }

    If (!longPaths) {
        cutChars := StrLen(curBasePath) + 2
    }
    For i,v in files {
        If (longPaths) {
            Loop Files, % RTrim(v, "\"), FD
            {
                filesList .= """\\?\" . A_LoopFileLongPath . ( (SubStr(v,0) == "\") ? "\*" : "" ) . """ "
            }
        } Else {
            filesList .= """" . SubStr(v, cutChars) . ( (SubStr(v,0) == "\") ? "*" : "" ) . """ "
        }
    }

    ;debug: MsgBox curBasePath: %curBasePath%`nfilesList: «%filesList%»
    ; because of following, on older systems only m1 and m3 are viable
    ;archiving r:\Depts Office Workstations\User Data\CommOps-Head\Marina\ (~18 Gb)
    ; 7-Zip LZMA2:	2 hours, 9.3 GB
    ; zpaq m1:	20 min,	10.2 GB
    ; zpaq m2:	55 min,	 9.9 GB
    ; zpaq m3:	55 min,  8.8 GB
    ; zpaq m4: 2h 15 m,	 8.4 GB
    ;on the new ones, m4 is fairly fast

    ;WaitCPUIdle(zpaqPID)
    method=m4
    Run %comspec% /U /C "CHCP 65001 & START "" /B /LOW /WAIT /D "\\?\%curBasePath%" %zpaqexe% a "%3%%arcName%.%method%.zpaq" %filesList% -%method% 2>>"%3%%arcName%.%method%.errors.log" %redirCmd% "%3%%arcName%.%method%.log" %cmdSuffix%",%curBasePath%,Min,zpaqPID
}

ExitApp

LongPathsInDir(dir) {
    dir := RTrim(dir, "\")
    remainingLen := 258 - StrLen(dir) ; 260 - StrLen('\0') - StrLen('\') - StrLen(base_path).
    ;If 1, there may still be 1-char-filenames in this directory
    If (remainingLen < 1)
        return 1
    VarSetCapacity(vFINDDATA, A_IsUnicode ? 592 : 520, 0)
    ;sizeof(WIN32_FIND_DATA) = 592 (Unicode) / 520 (ASCII)

    ;typedef struct _WIN32_FIND_DATA {
    ;  DWORD    dwFileAttributes;	//	4
    ;  FILETIME ftCreationTime;	//	8
    ;  FILETIME ftLastAccessTime;	//	8
    ;  FILETIME ftLastWriteTime;	//	8
    ;  DWORD    nFileSizeHigh;	//	4
    ;  DWORD    nFileSizeLow;	//	4
    ;  DWORD    dwReserved0;	//	4
    ;  DWORD    dwReserved1;	//	4
    ;  TCHAR    cFileName[MAX_PATH];	//	MAX_PATH*(A_IsUnicode+1)
    ;  TCHAR    cAlternateFileName[14];	//	14*(A_IsUnicode+1)
    ;} WIN32_FIND_DATA, *PWIN32_FIND_DATA, *LPWIN32_FIND_DATA;

    ;MAX_PATH=260

    ;#ifdef _UNICODE
    ;typedef wchar_t TCHAR;
    ;#else
    ;typedef char TCHAR;
    ;#endif
    ;https://habrahabr.ru/post/164193/

    ;Contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
    ;typedef struct _FILETIME {
    ;  DWORD dwLowDateTime;
    ;  DWORD dwHighDateTime;
    ;} FILETIME, *PFILETIME;

    hFile := DllCall("Kernel32.dll\FindFirstFile", "str", "\\?\" . dir . "\*", "ptr", &vFINDDATA)
    if (hFile = -1)
        Throw Exception(A_LastError, "Kernel32.dll\FindFirstFile", dir)
    subdirs := Object()
    Loop
    {
        ;vAttrib := NumGet(&vFINDDATA)
        ; https://msdn.microsoft.com/ru-ru/library/windows/desktop/gg258117.aspx
        ;attReadOnly	:= vAttrib & 0x1
        ;attHidden	:= vAttrib & 0x2
        ;attSystem	:= vAttrib & 0x4
        ;attDirectory	:= vAttrib & 0x10
        ;attArchive	:= vAttrib & 0x20
        ;attNormal	:= vAttrib & 0x80
        ;attTemporary	:= vAttrib & 0x100
        ;attSparse	:= vAttrib & 0x200
        ;attReparsePoint:= vAttrib & 0x400 ; A file or directory that has an associated reparse point, or a file that is a symbolic link
        ;attCompressed	:= vAttrib & 0x800
        ;attUnindexed	:= vAttrib & 0x2000
        ;attEncrypted	:= vAttrib & 0x4000
        fname := StrGet(&vFINDDATA+44)
        If (StrLen(fname) > remainingLen)
            return 1
        if fname not in .,..
        {
            If (NumGet(&vFINDDATA) & 0x10)
                subdirs.Push(fname)
        }
    } Until !DllCall("Kernel32.dll\FindNextFile", "ptr", hFile, "ptr", &vFINDDATA)
    DllCall("Kernel32.dll\FindClose", "ptr", hFile)

    For i,v in subdirs {
        If (LongPathsInDir(dir . "\" . v))
            return 1
    }
    return 0
}

WaitCPUIdle(pidToWait:=0, cpuLimit := 0.7, limitDuration := 15, processWaitTimeout := 120) {
    FileAppend Start waiting for idle CPU`n, *
    GetIdleTime()
    c:=0
    Loop
    {
        Sleep 1000
        idle := GetIdleTime()
        If (idle > cpuLimit)
            c++
        Else
            c := 0
    } Until c > limitDuration || (A_Index > processWaitTimeout && !ProcessExist(pidToWait))
}

;http://www.autohotkey.com/board/topic/11910-cpu-usage/
GetIdleTime() ;idle time fraction
{
    Static oldIdleTime, oldKrnlTime, oldUserTime
    Static newIdleTime, newKrnlTime, newUserTime

    oldIdleTime := newIdleTime
    oldKrnlTime := newKrnlTime
    oldUserTime := newUserTime

    DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
    Return (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)
}

ProcessExist(pid) {
    Process Exist, %pid%
    Return ErrorLevel
}

CommonPath(dir1, dir2) {
    dir1shn:=SubStr(dir1, 1, StrLen(dir2))
    dir2shn:=SubStr(dir2, 1, StrLen(dir1))
    If (dir1shn = dir2shn) {
        return dir1shn
    }

    Loop Parse, dir1shn, \
    {
        newCommonPath .= (A_Index > 1 ? "\" : "") . A_LoopField
        If (SubStr(dir2shn, 1, StrLen(newCommonPath)) != newCommonPath)
            return commonPath
        commonPath:=newCommonPath
    }
    Throw Exception("Should not happen",, "return should always happen before path parsing complete, since full path is compared before the loop")
}

Findzpaqexe() {
    Local
    If (A_Is64bitOS)
        namezpexe=zpaq64.exe
    Else
        namezpexe=zpaq.exe

    dirs=
    (LTrim Join;
        %A_ScriptDir%\..\bin
        %LocalAppData%\Programs\zpaq
        %LocalAppData%\Programs\zpaq*\*
        %Path%
    )

    Return FindExeInDirs(namezpexe, dirs)
}

FindTeeExe() {
    Local
    dirs=
    (LTrim Join;
        %A_ScriptDir%
        %SystemDrive%\SysUtils\UnxUtils
        %Path%
    )
    Return FindExeInDirs("tee.exe", dirs)
}

FindExeInDirs(exe, dirs) {
    Loop Parse, dirs, `;
    {
        If (SubStr(A_LoopField, -1)=="\*") {
            r := "R"
            dir := SubStr(A_LoopField, 1, -2)
        } Else {
            r=
            dir := A_LoopField
        }
        Loop Files, %A_LoopField%, D%r%
        {
            curPath := A_LoopFileFullPath . "\" . exe
            If (FileExist(curPath)) {
                FileGetTime curTime, %curPath%
                If (curTime > maxTime) {
                    out:=curPath, maxTime:=curTime
                }
            }
        }
    }

    If (!out)
        Throw Exception("Requested executable not found",, exe . " not found in " . dirs)
    return out
}
