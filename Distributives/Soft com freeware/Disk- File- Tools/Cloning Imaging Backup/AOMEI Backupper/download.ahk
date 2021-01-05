#NoEnv

rawupdateinfo := GetURL("http://www2.aomeisoftware.com/download/Autoupgrade/ABaotoupgrade/abupgrade.ini")
o := FileOpen("abupgrade.ini", "w"), o.Write(rawupdateinfo), o.Close()

Loop Parse, rawupdateinfo, `n, `r
{
    If (!A_LoopField)
        continue
    If (RegexMatch(A_LoopField, "\s*\[(?P<sect>[^\]]+)\]\s*", m)) {
        useSection := {package: 1,version: 2}[msect]
        continue
    }
    
    If (useSection) {
        p := StrSplit(A_LoopField, "=", " `t", 2)
        Switch useSection {
            Case 1:
                If (!url && p[1] == "url1")
                    url := p[2]
            Case 2:
                Switch p[1] {
                    Case "maj":
                        vermajor := p[2]
                    Case "min":
                        verminor := p[2]
                    Case "thrid":
                        verbuild := p[2]
                }
        }
    }
}

ver := vermajor "." verminor (verbuild ? "." verbuild : "")
SplitPath url, outFileName
outDir := A_ScriptDir "\" ver
FileCreateDir %outDir%

EnvGet SystemRoot, SystemRoot
RunWait %SystemRoot%\System32\curl.exe -R -z "%outFileName%" --output "%outFileName%" "%url%", %outDir%, Min
