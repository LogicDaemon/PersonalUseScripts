#NoEnv
#Warn

EnvGet SystemRoot, SystemRoot
Global SystemRoot

DownloadUpdates("http://www2.aomeisoftware.com/download/Autoupgrade/ABaotoupgrade/abupgrade.ini", "abupgrade.ini")
ExitApp

DownloadUpdates(ByRef url, filename) {
    FileRead oldUpdateInfo, %filename%
    rawupdateinfo := GetURL(url)
    If (oldUpdateInfo == rawupdateinfo)
        Return
    o := FileOpen("abupgrade.ini.new", "w"), o.Write(rawupdateinfo), o.Close()
    For _, verdata in ParseVersionInfo(rawupdateinfo)
        Download(verdata)
    FileMove abupgrade.ini.new, abupgrade.ini, 1
}

ParseVersionInfo(ByRef rawupdateinfo) {
    allVersions := []
    verdata := {}
    Loop Parse, rawupdateinfo, `n, `r
    {
        If (!A_LoopField)
            continue
        If (RegexMatch(A_LoopField, "\s*\[(?P<sect>[^\]]+)\]\s*", m)) {
            If (verdata.package.Count() && verdata.version.Count())
                allVersions.Push(verdata), verdata := {}
            sect := {package: {},version: {}}[msect]
            If (sect)
                verdata[msect] := sect, sectName := msect ; msect will get cleared on next RegexMatch
            continue
        }
        
        If (IsObject(sect)) {
            kv := StrSplit(A_LoopField, "=", " `t", 2)
            key := kv[1]
            value := kv[2]
            Switch sectName {
                Case "package":
                    If (key ~= "url\d*")
                        sect[key] := value
                Case "version":
                    verPartName := { "maj": "major"
                        , "min": "minor"
                        , "thrid": "build" }[key]
                    If (verPartName)
                        sect[verPartName] := value
                    Else
                        sect.suffix .= " " key "=" value
            }
        }
    }
    
    If (verdata.package.Count() && verdata.version.Count())
        allVersions.Push(verdata)
    return allVersions
}

Download(verdata) {
    v := verdata.version
    vername := v.major "." v.minor (v.build ? "." v.build : "")
    If (v.suffix)
        vername .= v.suffix
    vername := SubStr(vername, 1, 250)
    outDir := A_ScriptDir "\" vername
    FileCreateDir %outDir%
    
    For _, url in verdata.package {
        SplitPath url, outFileName
        RunWait %SystemRoot%\System32\curl.exe -R -z "%outFileName%" --output "%outFileName%" "%url%", %outDir%, Min
    }
}

#Include <GetURL>
