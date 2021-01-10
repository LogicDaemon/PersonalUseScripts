#NoEnv

keePassExePath := Find_KeePass_exe()
FileGetVersion KeePassExeVer, %keePassExePath%
distPathM := Find_Distributives_subpath("Soft FOSS\Cryption\Password Mangers\KeePass Password Safe\v1\KeePass-1.*.zip")
SplitPath distPathM,,distDir

webNewVer := GetKeepassUpdateVer()

If (VersionAtLeast(KeePassExeVer, webNewVer))
    Exit 1 ; current version is installed

distNewVer := [1,0,0]
Loop Files, %distPathM%
    If (RegexMatch(A_LoopFileName, "^KeePass-(?P<ver>1(?:\.\d+)*).zip$", m))
        distNewVer := VersionCompare(mver, distNewVer, false) ? mver : distNewVer

If (VersionCompare(distNewVer, webNewVer, false))
    RunWait "%A_AhkPath%" "%updaterPath%"

#include <find7zexe>

SplitPath keePassExePath,, keePassExeDir
RunWait "%exe7z%" x -o"%keePassExeDir%",, Min
Exit 0 ; Updated

GetKeepassUpdateVer() {
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
