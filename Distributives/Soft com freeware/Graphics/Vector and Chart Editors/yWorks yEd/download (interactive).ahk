#NoEnv

global baseurl:="http://www.yworks.com/products/yed/demo/"
;namepattern=yEd-3.12.2.zip
namepattern=yEd-*.zip

namepattern=yEd-*.zip
Loop %A_ScriptDir%\%namepattern%
{
    StringSplit namePart, A_LoopFileName, .
;    namePart0 must be 3 or 4
;    namePart1 yEd-3
;    namePart2 12 (1st subver)
;    namePart3 2 (build No, namePart0=4) or zip (ext, namePart0=3)
;    namePart4 zip (namePart0=4) or none
    If (namePart0=3)
	namePart3=
    
;    Current: ComposeURL(namePart1,namePart2,namePart3)
    
    If (TryDL(ComposeURL(namePart1,namePart2+2))
     && TryDL(ComposeURL(namePart1,namePart2+1))
     && TryDL(ComposeURL(namePart1,namePart2+1,"2"))
     && TryDL(ComposeURL(namePart1,namePart2+1,"1"))
     && TryDL(ComposeURL(namePart1,namePart2,(namePart3 ? namePart3+2 : 2 )))
     && TryDL(ComposeURL(namePart1,namePart2,(namePart3 ? namePart3+1 : 1 ))))
	Run http://www.yworks.com/en/products_download.php
    Else {
	Loop %A_ScriptDir%\%namepattern%
	    If (A_LoopFileName != lastSucessfullName)
		FileDelete %A_LoopFileName%
	RunWait C:\SysUtils\xln.exe "%A_ScriptDir%\temp\%lastSucessfullName%" "%A_ScriptDir%\%lastSucessfullName%", Min
    }
}

TryDL(url) {
    FileCreateDir %A_ScriptDir%\temp
    RunWait C:\SysUtils\wget.exe -nd -e robots=off --no-check-certificate --progress=dot:giga -o wget.log -N %url% , %A_ScriptDir%\temp, Min UseErrorLevel
    
    If A_LastError
	return A_LastError
    
    SplitPath url, OutFileName
    IfNotExist %A_ScriptDir%\temp\%OutFileName%
	return 1
	
    global lastSucessfullName:=OutFileName
}

ComposeURL(part1,part2,part3="") {
    return baseurl . part1 . "." . part2 . ( part3 ? "." . part3 : "") . ".zip"
}
