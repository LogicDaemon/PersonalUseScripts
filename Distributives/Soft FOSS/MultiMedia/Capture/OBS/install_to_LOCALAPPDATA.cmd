@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL find7zexe.cmd

    rem OBS-Studio-31.0.2-Windows-Installer.exe
    rem OBS-Studio-31.1.1-Windows-x64-Installer.exe
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D ^
                                        "%~dp0OBS-Studio-*-Windows-x64-Installer.exe" ^
                                        "%~dp0OBS-Studio-*-Windows-Installer.exe" ^
                                        "%~dp0OBS-Studio-*-Full-x64.zip" ^
                                        "%~dp0OBS-Studio-*-Full-Installer-x64.exe"^
                                      `) DO @(
        SET "dstfname=%%~A"
        GOTO :found
    )
    EXIT /B 1
)
:found
@(
    CALL :install "%dstfname%"
    FOR /D %%A IN ("%~dp0plugins\*") DO CALL :installplugin "%%~A"
    COMPACT /C /S:"%LOCALAPPDATA%\Programs\obs-studio" /EXE:LZX
EXIT /B
)
:install
@(
    %exe7z% x -xr!*.pdb -x!"$APPDATA" -x!"$PLUGINSDIR" -x!"uninstall.exe.nsis" -aos -y -o"%LOCALAPPDATA%\Programs\%~n1" -- "%~1" || EXIT /B
    ECHO N|RMDIR "%LOCALAPPDATA%\Programs\obs-studio"
    ECHO N|DEL "%LOCALAPPDATA%\Programs\obs-studio"
    MKLINK /D "%LOCALAPPDATA%\Programs\obs-studio" "%LOCALAPPDATA%\Programs\%~n1" || MKLINK /J "%LOCALAPPDATA%\Programs\obs-studio" "%LOCALAPPDATA%\Programs\%~n1"
    SET "installDest=%LOCALAPPDATA%\Programs\%~n1"
EXIT /B
)
:installplugin
@(
    SET "dstfname="
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D ^
                                        "%~1\*-win64.zip" ^
                                        "%~1\*-win64.7z" ^
                                        "%~1\*-win64.rar" ^
                                      `) DO @(
        %exe7z% x -xr!*.pdb -aos -y -o"%installDest%" -- "%%~A"
        EXIT /B
    )
    EXIT /B 1
)
