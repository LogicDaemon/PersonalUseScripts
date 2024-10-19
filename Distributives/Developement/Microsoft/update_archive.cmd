@(REM coding:CP866
REM unlicense (http://unlicense.org/) public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

winrar.exe a -m5 -s -r -md4g -oh -htb -oi -ol -qo- -ibck -- "%~dp0Microsoft.rar" "v:\ProgramData\Microsoft\VisualStudio" "v:\Program Files (x86)\Microsoft Visual Studio"
rem CHCP 65001 & START "" /B /LOW /WAIT /D "\\?\%~dp0" zpaq.exe a "%~dp0Microsoft.m4.zpaq" "v:\ProgramData\Microsoft\VisualStudio" "v:\Program Files (x86)\Microsoft Visual Studio" -m3 2>>"%~dp0Microsoft.m4.errors.log" >>"%~dp0Microsoft.m4.log"
)
