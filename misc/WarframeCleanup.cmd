@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

    FOR /D %%A IN (D:\Games W:\Temp) DO (
        PUSHD "%%~A\Steam\SteamApps\common\Warframe" && (
            DEL /Q Tools\*.TMP
            START "Compacting Warframe" /LOW %SystemRoot%\System32\compact.exe /C /S /EXE:LZX *.exe *.dll
        )
    )
)
