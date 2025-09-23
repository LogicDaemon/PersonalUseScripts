;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Files, %A_ScriptDir%\*.exe
{
    FileGetVersion ver, %A_LoopFileFullPath%
    FileCreateDir %A_ScriptDir%\%ver%
    Run %comspec% /C "MKLINK /H "%A_ScriptDir%\%ver%\%A_LoopFileName%" "%A_LoopFileFullPath%"",, Min UseErrorLevel
    If (ErrorLevel)
	FileAppend Error %ErrorLevel% linking "%A_ScriptDir%\%ver%\%A_LoopFileName%"`n, **
}
