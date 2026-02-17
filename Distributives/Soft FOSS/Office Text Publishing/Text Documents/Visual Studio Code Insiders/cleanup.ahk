;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

found := {}
lastVer := 0
lastDate := 0

Loop Files, %A_ScriptDir%\*.zip
{
	;VSCode-win32-x64-1.103.0-insider-05ca6dd1bd6690aa2be81cc940ec308e5acc1c3d.zip
	If (!RegexMatch(A_LoopFileName, ".*?-(?P<ver>\d+\.[\d\.]+)", m)) {
		Continue
	}
	found[A_LoopFileName] := [mver, A_LoopFileDateModified]
	If (VerCompare(mver, ">" lastVer)) {
		lastVer := mver
	}
	If (lastVer == mver && A_LoopFileDateModified > lastDate) {
		lastDate := A_LoopFileDateModified
	}
}

For file, ver in found {
	If (ver[1] != lastVer || ver[2] != lastDate) {
		FileDelete %A_ScriptDir%\%file%
	}
}
