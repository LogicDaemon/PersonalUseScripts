@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

7zg x -o"%TEMP%\PSS" "%~dp0pss4.0.5.rar"
msiexec /i "%TEMP%\PSS\Pro Surveillance System.msi" /q
RD /S /Q "%TEMP%\PSS"
