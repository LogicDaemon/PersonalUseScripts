@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem     SET "e=*.exe *.dll *.mui"
    SET "e=*.pdb *.sys *.eml *.qml *.js *.pyd *.py *.pyi *.qmltypes *.rcc *.inf *.manifest"
)
(
    FOR /R "%ProgramFiles(x86)%" %B IN (%e%) DO @IF %~zB GTR 4095 START "%~B" /low compact /C /Q /EXE:LZX "%~B"
    FOR /R "%ProgramFiles%" %B IN (%e%) DO @IF %~zB GTR 4095 START "%~B" /low compact /C /Q /EXE:LZX "%~B"
    FOR /R "%USERPROFILE%" %B IN (%e%) DO @IF %~zB GTR 4095 START "%~B" /low compact /C /Q /EXE:LZX "%~B"
    FOR /R "w:\Temp" %B IN (%e%) DO @IF %~zB GTR 4095 START "%~B" /low compact /C /Q /EXE:LZX "%~B")
)
