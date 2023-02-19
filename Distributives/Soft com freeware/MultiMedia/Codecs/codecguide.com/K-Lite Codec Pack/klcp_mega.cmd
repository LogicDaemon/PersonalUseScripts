@REM coding:OEM

REM -MakeUnattended
FOR /F "usebackq delims=" %%I IN (`DIR /B /O-N "%~dp0K-Lite_Codec_Pack_*_Mega.exe"`) DO (
    SET "dist=%~dp0%%~I"
    GOTO :ExitFor
)
:ExitFor
"%dist%" /verysilent /norestart /LoadInf="%~dpn0.ini"

REM Russian LangPack for TCPMP
rem 7z.exe x -aoa "%srcpath%mpcresources.ru.dll.7z" -o"%ProgramFiles%\K-Lite Codec Pack\Media Player Classic\"
