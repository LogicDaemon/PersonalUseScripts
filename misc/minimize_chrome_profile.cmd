@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

IF "%1"=="" (
    PUSHD "%LOCALAPPDATA%\Google\Chrome\User Data\Default" || EXIT /B
) ELSE (
    PUSHD %1 || EXIT /B
)
RD /s /q "databases"
RD /s /q "File System"
RD /s /q "IndexedDB"
RD /s /q "Local Storage"
RD /s /q "Pepper Data"
RD /s /q "Service Worker"
RD /s /q "Storage"
RD /s /q "Web Applications"

FOR /F "usebackq delims=" %%A IN ("%~dp0Chrome_Profile_Temporary.txt") DO RD /S /Q "%%~A"
FOR /F "usebackq delims=" %%A IN ("%~dp0Chrome_Profile_Compactable.txt") DO COMPACT /C /S /EXE:LZX "%%~A"
)
