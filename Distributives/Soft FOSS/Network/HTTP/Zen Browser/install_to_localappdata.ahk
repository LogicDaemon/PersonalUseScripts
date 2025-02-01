;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

#include <find7zexe>

distPath := LatestExisting(A_ScriptDir "\zen.installer.*.exe")
; zen.installer.1.7.4b.exe
If (!RegexMatch(distPath, "zen\.installer\.(.+)\.exe", ver))
    ExitApp 1
; ver1 = 1.7.4b
linkDest := LocalAppData "\Programs\Zen Browser"
outDir := LocalAppData "\Programs\Zen Browser " ver1
; If (FileExist(LocalAppData "\Programs\Zen Browser " ver1))
;     ExitApp 0

command = %exe7z% x -aoa -o"%outDir%.tmp\" -x!setup.exe -- "%distPath%"
RunOrRaise(command)

FileMoveDir %outDir%.tmp\core, %outDir%, R
FileRemoveDir %outDir%.tmp
FileDelete %linkDest%
RunWait %comspec% /C "MKLINK /J "%linkDest%" "%outDir%""

ExitApp

RunOrRaise(ByRef command, ByRef dir := "", ByRef params := "") {
    RunWait %command%, %dir%, %params%
    If (ErrorLevel)
        Throw Exception("ErrorLevel " ErrorLevel " executing command",, command)
}

#include <LatestExisting>
