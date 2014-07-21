@REM coding:OEM
@ECHO OFF
SETLOCAL
CALL _unison_get_command.cmd
IF NOT DEFINED syncprog SET syncprog=%unisontext%
IF "%~1"=="" (
    IF NOT DEFINED unisonopt SET unisonopt=-auto
) ELSE SET unisonopt=%unisonopt% %*

START "Unison server" /B %unisontext% -socket 10355
PING 127.0.0.1 -n 2>NUL
ECHO Synchronizing Distributives updated often
START "" /B /WAIT %syncprog% Distributives -path "Soft/AntiViruses AntiTrojans" -path "Soft/Disk- File- Tools/Synchronization Comparsion/Unison" -path "Soft/Graphics/Viewers Managers/FastPictureViewer" -path "Soft/Network/Chat Messengers/Blink" -path "Soft/Network/HTTP/Chromium" -path "Soft/Network/HTTP/Mozilla FireFox/latest-mozilla-central" -path "Soft/Network/Mail News/Mozilla Thunderbird/Extensions" -path "Soft/System/Other/Link Shell Extension (LSE)" -path "Soft_Updates" -batch %unisonopt%

ECHO Synchronizing Distributives
START "" /B /WAIT %syncprog% Distributives -path Soft -path Soft_Updates -path Developement %unisonopt%

ECHO Synchronizing Drivers
PUSHD o:\Distributives\Drivers
FOR /D %%I IN (*.*) DO CALL :CheckOptFileAndSync "%%I"
POPD

%unisontext% Distributives_Drivers -killserver -testserver -silent

ENDLOCAL
EXIT /B
:CheckOptFileAndSync
SETLOCAL
ECHO Syncing %~1
SET moreunisonopt=
IF EXIST "%~1\unison_opt.txt" FOR /F "usebackq delims=" %%k IN ("%~1\unison_opt.txt") DO SET moreunisonopt=%%k
%unisontext% Distributives_Drivers -path "Drivers\%~1" %unisonopt% %moreunisonopt%
ENDLOCAL
