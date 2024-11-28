;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

compression_args := "-mx=9 -m0=LZMA2:a=2:fb=273 -mqs"

args := ParseScriptCommandLine()
exe7z := find7zGUIorAny()
Run %exe7z% a %compression_args% -sdel -- _html_and_doc.7z %args%
Exit

#include <find7zexe>
#include <ParseScriptCommandLine>
