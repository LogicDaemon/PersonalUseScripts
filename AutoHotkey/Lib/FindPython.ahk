FindPython(ByRef exeName := "python.exe") {
    Local
    Global LocalAppData

    EnvGet VIRTUAL_ENV, VIRTUAL_ENV
    If (VIRTUAL_ENV) ; assume the exe is in PATH
        Return exeName

    lLocalAppData := LocalAppData
    If (!lLocalAppData)
        EnvGet lLocalAppData, LocalAppData
    If (FileExist(pyexePath := FindScoopBaseDir() "\apps\python\current\" exeName))
        Return pyexePath
    latestFound := ""
    For _, RootKey in [ "HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE" ] {
        Loop Reg, %RootKey%\Software\Python\PythonCore, K
        {
            ; RegRead OutputVar, HKLM|HKU|HKCU|HKCR|HKCC, SubKey [, ValueName]
            ; RegRead sysVersion, %RootKey%\Software\Python\PythonCore\%A_LoopRegName%, SysVersion
            RegRead pyVersion, %RootKey%\Software\Python\PythonCore\%A_LoopRegName%, Version
            Loop Reg, %RootKey%\Software\Python\PythonCore\%A_LoopRegName%\InstallPath, V
            {
                RegRead path
                SplitPath path, foundName
                If (foundName != exeName || VerCompare(pyVersion, "<=" latestFound) || !FileExist(path))
                    Continue
                latestFound := pyVersion, latestPath := path
                Break
            }
        }
    }
    If (latestFound)
        Return latestPath

    ; The names in the installation path are something like "Python39" or "Python310"
    ; and "310" is obviously greater. Theoretically it also could switch to something
    ; like "Python3145" (for 3.14.5) or "Python3.15" so comparing as plain numbers
    ; is not future-proof. Instead, cut off "Python *3?\.?" from the front, then split
    ; the remaining to minor (at most two digits) and patch.
    EnvGet ProgramFilesx86, ProgramFiles(x86)
    For baseDir in [ lLocalAppData "\Programs\Python"
                   , A_ProgramFiles "\Python"
                   , ProgramFilesx86 "\Python" ] {
        If (!InStr(FileExist(baseDir), "D"))
            Continue
        Loop Files, %baseDir%\*, D
        {
            If (!RegExMatch(A_LoopFileName, "i)^Python *3\.?(\d{1,2}).?(\d{0,5})$", m)
                || !FileExist(exePath := A_LoopFileFullPath "\" exeName))
                Continue
            pyVersion := Format("{}.{}", m1, m2)
            If (VerCompare(pyVersion, ">" latestFound)) {
                latestFound := pyVersion, latestPath := exePath
            }
        }
    }
    Return latestPath
}

#include <FindScoopBaseDir>