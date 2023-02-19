@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    
    ECHO src: %1
    ECHO dest: %2

    FOR /F "usebackq delims=" %%A IN (`FORFILES /S /P %1 /C "CMD /C \"ECHO @relpath\""`) DO @(
        SET "relpath=%%~A"
        CALL :LinkFlat "%~1\%%~A" %2
    )
    EXIT /B
)
:LinkFlat <src>
@IF "%relpath:~0,2%"==".\" SET "relpath=%relpath:~2%"
@SET "dest=%relpath::=_%"
@SET "dest=%dest:\=_%"
@(
    MKLINK /H "%dest:/=_%" %1
    EXIT /B
)
