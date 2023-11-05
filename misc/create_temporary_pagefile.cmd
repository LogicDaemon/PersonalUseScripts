@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~nx1"=="" (
        SET "swappath=%~1\pagefile.sys"
    ) ELSE (
        SET "swappath=%~1"
    )
    IF NOT DEFINED swappath GOTO :help

    SET "minsize=%~2"
    IF NOT DEFINED minsize GOTO :help

    SET "maxsize=%~3"
)
@(
    SET "wmicpath=%swappath:\=\\%"
    IF NOT DEFINED maxsize SET "maxsize=%minsize%"
)
@(
    wmic.exe pagefileset create name="%wmicpath%"
    wmic.exe pagefileset where name="%wmicpath%" set InitialSize=%minsize%,MaximumSize=%maxsize%
    ECHO The pagefile should be created now.
:recheck
    TIMEOUT /T 10
    wmic.exe pagefileset where name="%wmicpath%" delete
    EXIT /B
)

:help
@(
    ECHO %0 path minsize [maxsize]
    ECHO path can include filename, otherwise pagefile.sys assumed;
    ECHO minsize and maxsize are in megabytes
EXIT /B
)
