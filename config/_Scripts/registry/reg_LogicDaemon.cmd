@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO ��ਯ� "%~f0" ��� �ࠢ ����������� �� ࠡ�⠥� & PING -n 30 127.0.0.1 >NUL & EXIT /B )

SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    SET "TempDir=%TEMP%\%~n0"
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    %exe7z% x -aoa "%~dp0User.7z" -o"%TempDir%" || PAUSE
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "REM -!!! Registry Files List -" "%~f0"`) DO SET skiplines=%%I
)
(
    PUSHD "%TempDir%" && (
	FOR /F "usebackq skip=%skiplines% eol=; tokens=*" %%A IN ("%~f0") DO FOR %%I IN ("%%A") DO %SystemRoot%\System32\REG.exe IMPORT "%%~I"
	POPD
    )
    RD /S /Q "%TempDir%"
    EXIT /B
)
REM -!!! Registry Files List -
Animation_Disable.reg
disable OneDrive.reg
Disable_LinkFile_Tracking.reg
DontUsePowerShellOnWinX.reg
No_Sounds.reg
no_thumbnail_cache.reg
NoDrivesInSendToMenu.reg
Show_Phantom_Devices_and_Details_CU.reg
SystemPaneSuggestionsEnabled.reg
turn-off-ads-windows-10.reg
Win10 Disable Visual Effects for non-admin users.reg
