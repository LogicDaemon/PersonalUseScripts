@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO ��ਯ� "%~f0" ��� �ࠢ ����������� �� ࠡ�⠥� & PING -n 30 127.0.0.1 >NUL & EXIT /B )

SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "TempDir=%TEMP%\%~n0"
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    %exe7z% x -aoa "%~dp0System.7z" -o"%TempDir%" || PAUSE
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
for_all\CEIPEnable=0.reg
for_all\disable OneDrive.reg
for_all\DisableStrictNameChecking.reg
for_all\DisableWindowsConsumerFeatures.reg
for_all\Dont Prelaunch Edge.reg
for_all\LMCompatibilityLevel.reg
for_all\MRT - DontReportInfectionInformation.reg
for_all\NcdAutoSetup-Private-Disable.reg
for_all\NoThumbnailCache LM.reg
for_all\Show_Phantom_Devices_Details_LM.reg
for_all\Show_Phantom_Devices_LM.reg
less_careful\networking\EnablePMTUBHDetect.reg
less_careful\networking\EnablePMTUDiscovery.reg
less_careful\networking\GlobalMaxTcpWindowSize.reg
less_careful\IE_ErrorReportings_Disable.reg
less_careful\IE_NoUpdateCheck.reg
ui\common\Animation_Disable.reg
ui\common\BootTime_AutoCheck_CountDown.reg
ui\common\No_Sounds.reg
ui\common\NoDrivesInSendToMenu.reg
UI\other\own_preference\VerboseStatus.reg
