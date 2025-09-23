;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

; include to auto-execute section to run this during initialization. Maybe define exe7z global beforehand.
Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()
If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    FileAppend %exe7z%`n,*,CP1
    
    Exit
}

find7zexe(exename:="7z.exe", paths*) {
    local ; regPaths, bakRegView, i, regpath, currpath, ProgramFilesx86, SystemDrive, path, fullpath
    ;key, value, flag "this is path to exe (only use directory)"
    static regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,true]
                       ,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
                       ,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,true]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
                       ,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", true] ]
    
    bakRegView := A_RegView
    SetRegView 64
    For i,regpath in regPaths {
        Try {
            RegRead currpath, % regpath[1], % regpath[2]
            If (currpath) {
                If (regpath[3]) 
                    SplitPath currpath,,currpath
                SetRegView %bakRegView%
                return Check7zDir(Trim(currpath,""""), exename)
            }
        }
    }
    SetRegView %bakRegView%
    
    If (IsFunc("findexe")) {
        EnvGet ProgramFilesx86,ProgramFiles(x86)
        EnvGet SystemDrive,SystemDrive
        Try return Func("findexe").Call(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
        Try return Func("findexe").Call("7za.exe", SystemDrive . "\Arc\7-Zip")
    }
    
    For i,path in paths {
        Loop Files, %path%, D
        {
            fullpath=%A_LoopFileLongPath%\%exename%
            If (FileExist(fullpath))
                return fullpath
        }
    }
    
    Throw Exception("7-Zip not found",, exename)
}

Check7zDir(dir7z, exename := "7z.exe") {
    local ; Force-local mode
    dir7z:=RTrim(dir7z,"\")
    If (!dir7z)
        Throw Exception("Null path specified as directory")
    If (!FileExist(exe7z := dir7z "\" exename))
        Throw Exception("File not found in dir",, """" exename """ in """ dir7z """")
    return exe7z
}

find7zaexe(paths*) {
    paths.push(	  "\Distributives\Soft\PreInstalled\utils"
                , "D:\Distributives\Soft\PreInstalled\utils"
                , "\\localhost\Distributives\Soft\PreInstalled\utils"
                , A_LineFile "\..\..\..\..\Soft\PreInstalled\utils")
    If (A_Is64bitOS)
        Try return find7zexe("7za64.exe", paths*)
    return find7zexe("7za.exe", paths*)
}

find7zGUIorAny(paths*) {
    Try return find7zexe("7zg.exe", paths*)
    Try return find7zexe("7z.exe", paths*)
    return find7zaexe(paths*)
}

;The FileName parameter may optionally be preceded by *i and a single space, which causes the program to ignore any failure to read the included file. For example: #Include *i SpecialOptions.ahk. This option should be used only when the included file's contents are not essential to the main script's operation.
#include *i %A_LineFile%\..\findexe.ahk
