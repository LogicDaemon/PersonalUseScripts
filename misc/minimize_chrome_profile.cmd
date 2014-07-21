@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

RD /s /q "Application Cache"
RD /s /q "Cache"
RD /s /q "data_reduction_proxy_leveldb"
RD /s /q "databases"
RD /s /q "File System"
RD /s /q "GCM Store"
RD /s /q "GPUCache"
RD /s /q "IndexedDB"
RD /s /q "Local Storage"
RD /s /q "Media Cache"
RD /s /q "Pepper Data"
RD /s /q "Service Worker"
RD /s /q "Session Storage"
RD /s /q "Storage"
RD /s /q "Web Applications"
)
