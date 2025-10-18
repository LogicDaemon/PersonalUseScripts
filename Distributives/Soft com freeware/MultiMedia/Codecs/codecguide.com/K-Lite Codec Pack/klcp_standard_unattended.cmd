@(REM coding:OEM
ECHO . Installing: K-Lite Codec Pack
FOR /F "usebackq delims=" %%A IN (`DIR /O-D "%~dp0K-Lite_Codec_Pack_*_Standard.exe"`) DO @(
"%%~A" /VERYSILENT /NORESTART /SUPPRESSMSGBOXES /LOADINF="%~dp0klcp_standard_unattended.ini"
IF ERRORLEVEL 1 GOTO :fail
ECHO . Done!
EXIT /B
)
)
:fail
@(
ECHO ! Failed, error %ERRORLEVEL%
EXIT %ERRORLEVEL%
)
