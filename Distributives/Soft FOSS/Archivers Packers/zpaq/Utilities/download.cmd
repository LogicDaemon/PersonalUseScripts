@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

    SET "srcpath=%~dp0"
    SET noarchmasks=*.zpaq *.zip 
    CALL wget_the_site.cmd mattmahoney.net https://mattmahoney.net/dc/zpaqutil.html -np
    
    IF NOT EXIST "%~dp0dc" MKDIR "%~dp0dc"
    FOR %%A IN ("%~dp0\temp\mattmahoney.net\dc\*.*") DO IF %%~zA GTR 0 MKLINK /H "%~dp0dc\%%~nxA" "%%~A" 
)
