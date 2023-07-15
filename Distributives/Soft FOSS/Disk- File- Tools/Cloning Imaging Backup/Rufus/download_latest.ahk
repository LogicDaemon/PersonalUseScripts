;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

verData := GetNewRufusVerData()

SplitPath % verData.download_url, filename

url := verData.download_url
EnvSetIfUnset("srcpath", A_ScriptDir "\")
EnvSetIfUnset("baseScripts", "\Local_Scripts\software_update\Downloader")
EnvGet baseWorkdir, baseWorkdir
If (!baseWorkdir) {
    baseWorkdir := A_ScriptDir "\temp"
    EnvSet baseWorkdir, %baseWorkdir%
}
FileCreateDir %baseWorkdir%
EnvSet dstrename, %filename%
RunWait %comspec% /C "PUSHD "`%srcpath`%" & CALL "`%baseScripts`%\_DistDownload.cmd" "%url%" "*.exe" -N >"`%baseWorkdir`%\`%dstrename`%.log" 2>&1", %A_Temp%, Min UseErrorLevel

GetNewRufusVerData() {
    verData :=  { "version": ""
                , "download_url": "" }
    count := verData.Count()
    ;version = 3.14.1788
    ;platform_min = 6.1
    ;download_url = https://github.com/pbatard/rufus/releases/download/v3.14/rufus-3.14.exe
    ;download_url_arm = https://github.com/pbatard/rufus/releases/download/v3.14/rufus-3.14_arm.exe
    ;download_url_arm64 = https://github.com/pbatard/rufus/releases/download/v3.14/rufus-3.14_arm64.exe
    ;release_notes = ...multiline RTF here...

    Loop Parse, % GetNewRufusVerURL(), `n, `r
    {
        nameValueSplitPos:=InStr(A_LoopField, "=")
        k := Trim(SubStr(A_LoopField, 1, NameValueSplitPos-1))
        If (verData.HasKey(k)) {
            verData[k] := Trim(SubStr(A_LoopField, NameValueSplitPos+1))
            If (count==1)
                break
            count--
        }
    }
    return verData
}

GetNewRufusVerURL() {
    For i, url in [   "https://rufus.ie/Rufus_win_x64_10.0.ver"
                    , "https://rufus.ie/Rufus_win_x64_10.ver"
                    , "https://rufus.ie/Rufus_win_x64.ver"
                    , "https://rufus.ie/Rufus_win.ver" ]
        Try return GetURL(url, 1)
}

EnvSetIfUnset(ByRef name, ByRef val) {
    local
    EnvGet current, %name%
    If (!current)
        EnvSet %name%, %val%
}
