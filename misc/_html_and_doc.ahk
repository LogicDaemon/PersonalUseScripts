;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
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
