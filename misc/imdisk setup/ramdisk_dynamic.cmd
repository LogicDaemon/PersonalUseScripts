@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

SET "size=%~1"
IF NOT DEFINED size FOR /F "usebackq delims=" %%A IN (`powershell -NoProfile -Command "(Get-Counter '\numa node memory(_total)\total mbytes').CounterSamples.CookedValue"`) DO SET "memSize=%%~A"
SET /A size=memSize/3

rem RamDyn.exe MountPoint Size|ImageFile CleanRatio|TRIM [CleanTimer CleanMaxActivity] PhysicalMemory BlockSize AddParam

rem * MountPoint: a drive letter followed by a colon, or the full path to an empty NTFS folder.
rem * Size|ImageFile: size of the volume, in KB. With at least one non-numeric character, it is assumed to be the name of an image file to load. 0 triggers the cleanup function for the specified mount point, if TRIM is not used (following parameters are ignored).
rem * CleanRatio: with -1, TRIM commands are used in replacement of the cleanup function, and the 2 following parameters are not used; otherwise, it's an approximate ratio, per 1000, of the total drive space from which the cleanup function attempts to free the memory of the deleted files (default: 10).
rem * CleanTimer: minimal time between 2 cleanups (default: 10).
rem * CleanMaxActivity: the cleanup function waits until reads and writes are below this value, in MB/s (default: 10).
rem * PhysicalMemory: use 0 for allocating virtual memory, 1 for allocating physical memory (default: 0); allocating physical memory requires the privilege to lock pages in memory in the local group policy.
rem * BlockSize: size of memory blocks, in power of 2, from 12 (4 KB) to 30 (1 GB) (default: 20).
rem * AddParam: additional parameters to pass to imdisk.exe. Use double-quotes for zero or several parameters.

REM DO NOT ENABLE AWE (physical memory) on Windows 10!!!

REM                                                     -1 = TRIM commands are used in replacement of the cleanup function
REM                                                      | 0 for allocating virtual memory, 1 for allocating physical memory
REM                                                      | | 2^26 = 64MB - it's the size of memory block
REM                                                      | | |
)
START "" "%ProgramFiles%\ImDisk\RamDyn.exe" "R:" %size% -1 0 26 "-p \"/fs:ntfs /q /y\""
:wait
@(
IF EXIST R:\Temp EXIT /B
PING -n 2 127.0.0.1 >NUL
MKDIR R:\Temp 2>NUL
GOTO :wait
)
