@REM coding:OEM
SETLOCAL

IF "%RunUnteractiveInstalls%"=="1" (
    SET switches=%switches% /passive
) ELSE (
    SET switches=%switches% /q
)

IF NOT DEFINED MSILog SET MSILog=%TEMP%\CRRedist2005_x86-install.log
SET switches=%switches% /log "%MSILog%"

msiexec /i "%~dp0CRRedist2005_x86.msi" /norestart %switches%