@REM coding:OEM
@ECHO OFF
SETLOCAL
CALL _unison_get_command.cmd
IF NOT DEFINED syncprog SET syncprog=%unisontext%
IF "%~1"=="" (
    IF NOT DEFINED unisonopt SET unisonopt=-auto
) ELSE SET unisonopt=%unisonopt% %*

rem SET UNISONLOCALHOSTNAME=LogicDaemonHome

rem START "Unison server" /B %unisontext% -socket 10353
rem START "Syncing Distributives_un" /B /WAIT %syncprog% Distributives_un -root t:\Distributives -killserver %unisonopt%
rem IF ERRORLEVEL 1 ECHO 

rem CALL sync_Distributives.cmd

START "Unison server" /B %unisontext% -socket 10355
ECHO Synchronizing Distributives updated often
START "" /B /WAIT %syncprog% Distributives -root t:\Distributives -path "Soft/AntiViruses AntiTrojans" -path "Soft/Disk- File- Tools/Synchronization Comparsion/Unison" -path "Soft/Graphics/Viewers Managers/FastPictureViewer" -path "Soft/Network/Chat Messengers/Blink" -path "Soft/Network/HTTP/Chromium" -path "Soft/Network/HTTP/Mozilla FireFox/latest-mozilla-central" -path "Soft/Network/Mail News/Mozilla Thunderbird/Extensions" -path "Soft/System/Other/Link Shell Extension (LSE)" -path "Soft_Updates" -batch %unisonopt%
IF ERRORLEVEL 1 ECHO 

ECHO Synchronizing Distributives
START "" /B /WAIT %syncprog% Distributives -root t:\Distributives -path Soft -path Soft_Updates %unisonopt%
IF ERRORLEVEL 1 ECHO 

ECHO Synchronizing Drivers
PUSHD t:\Distributives\Drivers
    FOR /D %%I IN (*.*) DO IF EXIST "w:\Distributives\Drivers\%%~I" CALL :CheckOptFileAndSync "%%~I"
POPD

%unisontext% Distributives_Drivers -root t:\Distributives -killserver -testserver -silent

rem END sync_Distributives.cmd

rem START "Unison server" /B %unisontext% -socket 10351
rem START "Syncing pic" /B /WAIT %syncprog% pic -killserver %unisonopt%
rem IF ERRORLEVEL 1 ECHO 
rem START "Unison server" /B %unisontext% -socket 10352
rem START "Syncing Photo" /B /WAIT %syncprog% Photo -killserver %unisonopt%
rem IF ERRORLEVEL 1 ECHO 
REM START "" /B %unisontext% -socket 10354
REM START "" /B /WAIT %syncprog% bb4win -killserver %unisonopt%

ENDLOCAL

EXIT /B
:CheckOptFileAndSync
SETLOCAL
ECHO Syncing %~1
SET moreunisonopt=
IF EXIST "%~1\unison_opt.txt" FOR /F "usebackq delims=" %%k IN ("%~1\unison_opt.txt") DO SET moreunisonopt=%%k
%unisontext% Distributives_Drivers -root t:\Distributives -path "Drivers\%~1" %unisonopt% %moreunisonopt%
IF ERRORLEVEL 1 ECHO 
ENDLOCAL
