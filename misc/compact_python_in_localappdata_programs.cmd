@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /D %%D IN ("%LocalAppData%\Programs\Python\*.*") DO (
        COMPACT /C /EXE:LZX /S:"%%~D\tcl"
        COMPACT /C /EXE:LZX /S:"%%~D\Tools"
        COMPACT /C /EXE:LZX /S:"%%~D\Doc"
        COMPACT /C /EXE:LZX /S:"%%~D\include"
        COMPACT /C /EXE:LZX /S:"%%~D\Lib"
        COMPACT /C /EXE:LZX /S:"%%~D\libs"
        COMPACT /C /EXE:LZX /S:"%%~D" *.py *.pyc *.pyi *.ico *.txt
        COMPACT /C /EXE:LZX "%%~D\pythonw.exe"
    )
)
