@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
@IF NOT DEFINED syncprog SET "syncprog=%unisontext%"
%unisontext% Distributives_AcerPH315-53-71HN -path "Soft/Keyboard Tools/AutoHotkey/ver.zip.txt" -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch
@FOR %%A IN ("%USERPROFILE%\.unison\*_AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" %unisonopt%
