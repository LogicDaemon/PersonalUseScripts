;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

scoopBase=%LocalAppData%\Programs\scoop
bucketDir=%scoopBase%\buckets\fixes
runmode=Hide

RunWait git pull, %bucketDir%, %runmode% UseErrorLevel
RunWait powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ".\bin\checkver.ps1" -Update cursor, %bucketDir%, %runmode% UseErrorLevel
RunWait powershell.exe -noprofile -ex unrestricted -file "%scoopBase%\apps\scoop\current\bin\scoop.ps1" update cursor, %scoopBase%, %runmode% UseErrorLevel
