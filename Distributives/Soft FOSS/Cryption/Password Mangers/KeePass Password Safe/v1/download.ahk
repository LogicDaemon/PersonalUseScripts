#NoEnv

versions := GetUrl("https://www.dominik-reichl.de/update/version1x.txt")
;KeePass#1.38.0.0
;Another Backup Plugin for KeePass#1.12.0.0
;DB Backup plugin for KeePass#1.6.0.4
;EWallet Import KeePass Plugin#1.15.0.0
;KeePT: WinPT plugin for KeePass#1.2.0.0
;LockExtensions Plugin#1.2.0.0
;On-Screen Keyboard Plugin#2.1.0.0
;Oubliette Import Plugin#1.15.0.0
;PuttyAgent Plugin#3.0.0.0
;RmvDup Plugin#1.2.0.0
;TanUpgrade Plugin#1.4.0.0
;Test Plugin#1.4.0.0
;VariousImport#1.2.0.0

Loop Parse, versions, `n, `r
{
    separator := InStr(A_LoopField, "#")
    progName := SubStr(A_LoopField, 1, separator-1)
    
    If (progName = "KeePass") {
        ver := SubStr(A_LoopField, separator+1)
        While EndsWith(ver, ".0")
            ver := SubStr(ver, 1, -2)
        break
    }
}

URLs := { "KeePass-*-Setup.exe": "https://sourceforge.net/projects/keepass/files/KeePass%201.x/*/KeePass-*-Setup.exe/download"
        , "KeePass-*.zip":       "https://sourceforge.net/projects/keepass/files/KeePass%201.x/*/KeePass-*.zip/download" }

EnvSetIfUnset("srcpath", A_ScriptDir "\")
EnvSetIfUnset("baseScripts", "\Local_Scripts\software_update\Downloader")
EnvGet baseWorkdir, baseWorkdir
If (!baseWorkdir) {
    baseWorkdir := A_ScriptDir "\temp"
    EnvSet baseWorkdir, %baseWorkdir%
}
FileCreateDir %baseWorkdir%
For filename, url in URLs {
    url := StrReplace(url, "*", ver)
    EnvSet dstrename, % StrReplace(filename, "*", ver)
    RunWait %comspec% /C "PUSHD "`%srcpath`%" & CALL "`%baseScripts`%\_DistDownload.cmd" "%url%" "%filename%" -m -l 1 -nd -H -D downloads.sourceforge.net -e "robots=off" -p "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >"`%baseWorkdir`%\`%dstrename`%.log" 2>&1", %A_Temp%, Min UseErrorLevel
    RunWait %comspec% /C "PUSHD "`%srcpath`%" & CALL "`%baseScripts`%\_DistDownload.cmd" "%url%" "%filename%@viasf=1" -m -l 1 -nd -H -D downloads.sourceforge.net -e "robots=off" -p "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >"`%baseWorkdir`%\`%dstrename`%.log" 2>&1", %A_Temp%, Min UseErrorLevel
    ;RunWait %comspec% /C "MKLINK /H "%A_ScriptDir%\%filename%" "%A_ScriptDir%\temp\%filename%@viasf=1"", %A_Temp%, Min UseErrorLevel
    ;If (ErrorLevel)
    ;    FileCopy %A_ScriptDir%\temp\%filename%@viasf=1, %A_ScriptDir%\%filename%
}

ExitApp

EnvSetIfUnset(ByRef name, ByRef val) {
    local
    EnvGet current, %name%
    If (!current)
        EnvSet %name%, %val%
}

;GET /project/keepass/KeePass%201.x/1.38/KeePass-1.38-Setup.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fkeepass%2Ffiles%2FKeePass%25201.x%2F1.38%2FKeePass-1.38-Setup.exe%2Fdownload&ts=1606576112&use_mirror=deac-riga HTTP/1.1
;Host: downloads.sourceforge.net
;Connection: keep-alive
;Upgrade-Insecure-Requests: 1
;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36
;Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
;Sec-Fetch-Site: same-site
;Sec-Fetch-Mode: navigate
;Sec-Fetch-Dest: document
;Referer: https://sourceforge.net/projects/keepass/files/KeePass%201.x/1.38/KeePass-1.38-Setup.exe/download?use_mirror=deac-riga&r=https%3A%2F%2Fkeepass.info%2Fdownload.html&use_mirror=deac-riga
;Accept-Encoding: gzip, deflate, br
;Accept-Language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7,de;q=0.6
;Cookie: _ga=GA1.2.774676249.1606574960; _gid=GA1.2.1034389356.1606574960; __adroll_fpc=2a1ab32ed6635388bd3a64c1e7dff6b1-1606575921702; _fbp=fb.1.1606575924068.845124996; __ar_v4=3QEU55AVURGVNFYKGPRLHU%3A20201128%3A5%7CEPGGWMNOENDCJMRYE2IIFV%3A20201128%3A5%7COLCQG7YFPFB7ZDDI7VV6SN%3A20201128%3A5; __gads=ID=e679cfcfb751c1c0:T=1606575903:S=ALNI_Ma5jpUsCDZ51aCUG3gvHnEtsgBSMA
