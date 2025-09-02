;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

found := {}
lastVer := 0

Loop Files, %A_ScriptDir%\*.zip
{
	;VSCode-win32-x64-1.103.0-insider-05ca6dd1bd6690aa2be81cc940ec308e5acc1c3d.zip
	If (!RegexMatch(A_LoopFileName, ".*?-(?P<ver>\d+\.[\d\.]+)", m)) {
		Continue
	}
	If (VerCompare(mver, ">" . lastVer)) {
		lastVer := mver
	}
	found[A_LoopFileName] := mver
}

For file, ver in found {
	If (ver != lastVer) {
		FileDelete %A_ScriptDir%\%file%
	}
}
