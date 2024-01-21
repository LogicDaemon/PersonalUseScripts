@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem     SET "e=*.exe *.dll *.mui"
    SET "extra=*.pdb *.sys *.eml *.qml *.js *.pyd *.py *.pyi *.qmltypes *.rcc *.inf *.manifest"
    SET "exe=*.dll *.exe"
)
(
    COMPACT /C /Q /EXE:LZX /S:"v:\Program Files (x86)" %extra% %exe%
rem     FOR /R "%ProgramFiles(x86)%" %%B IN (%extra%) DO @IF %%~zB GEQ 4096 START "%%~B" /low compact /C /Q /EXE:LZX "%%~B"
rem     FOR /R "%ProgramFiles%" %%B IN (%extra%) DO @IF %%~zB GEQ 4096 START "%%~B" /low compact /C /Q /EXE:LZX "%%~B"
rem     FOR /R "%USERPROFILE%" %%B IN (%extra% %exe%) DO @IF %%~zB GEQ 4096 START "%%~B" /low compact /C /Q /EXE:LZX "%%~B"
rem     FOR /R "w:\Temp" %%B IN (%extra% %exe%) DO @IF %%~zB GEQ 4096 START "%%~B" /low compact /C /Q /EXE:LZX "%%~B")
)
