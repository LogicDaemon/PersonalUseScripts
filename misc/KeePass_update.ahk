#NoEnv
#Warn

Try {
    keePassExePath := Find_KeePass_exe()
    FileGetVersion KeePassExeVer, %keePassExePath%
} Catch {
    EnvGet LocalAppData,LocalAppData
    keePassExePath := LocalAppData "\Programs\KeePass\KeePass.exe" 
    KeePassExeVer := 1
}
distPathM := Find_Distributives_subpath("Soft FOSS\Cryption\Password Mangers\KeePass Password Safe\v1\KeePass-1.*.zip")
SplitPath distPathM,,distDir

webNewVer := GetKeepassUpdateVer(distDir)
If (VersionAtLeast(KeePassExeVer, webNewVer))
    Exit 1 ; current version is installed

Loop 2
{
    distNewVer := [1,0,0]
    Loop Files, %distPathM%
        If (RegexMatch(A_LoopFileName, "^KeePass-(?P<ver>1(?:\.\d+)*).zip$", m)
            && VersionCompare(mver, distNewVer, false)) {

            distNewVer := mver
            distLatest := A_LoopFileLongPath
        }
    If (A_Index == 1 && VersionCompare(webNewVer, distNewVer, false))
        RunWait "%A_AhkPath%" "%distDir%\download.ahk"
    Else
        break
}
#include <find7zexe>
SplitPath keePassExePath,, keePassExeDir
RunWait "%exe7z%" x -y -aoa -o"%keePassExeDir%.%distNewVer%" "%distLatest%",, Min
RunWait %comspec% /C "MKLINK /J "%keePassExeDir%.tmp" "%keePassExeDir%.%distNewVer%""
FileRemoveDir %keePassExeDir%
FileMoveDir %keePassExeDir%.tmp, %keePassExeDir%, R
Exit ErrorLevel

GetKeepassUpdateVer(ByRef distDir := "") {
    local
    versions := GetUrl("https://www.dominik-reichl.de/update/version1x.txt")
    If (!versions)
        return
    ;KeePass#1.38.0.0
    ;...#1.12.0.0

    Loop Parse, versions, `n, `r
    {
        separator := InStr(A_LoopField, "#")
        progName := SubStr(A_LoopField, 1, separator-1)
        
        If (progName = "KeePass") {
            return SubStr(A_LoopField, separator+1)
        }
    }
}

#Warn Unreachable, Off

#include <find_KeePass_exe>
#include <GetURL>
#include <VersionCompare>
