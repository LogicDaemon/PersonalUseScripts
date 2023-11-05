@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

IF NOT EXIST u:\Backups\V_Various EXIT /B
SET "backupsDest=u:\Backups\V_Various"
FOR %%A IN (v:\Archive v:\Games\Spring v:\Games\ModOrganizer v:\MultiMedia) DO @CALL :zpaq_compress_dir %%A

EXIT /B
)
:zpaq_compress_dir
@(
    SET "src=%~1"
    SET "archiveName=%~pnx1"
)
@SET "archiveName=%archiveName:~1%"
@SET "archiveName=%archiveName:\=_%"
@SET "archiveBasePath=%backupsDest%\%archiveName%.m3"
@(
    SET "archivePath=%archiveBasePath%.zpaq"
    SET "errorLog=%archiveBasePath%.errors.log"
    SET "stdoutLog=%archiveBasePath%.log"
)
(
    START "%src% -> %backupsDest%" /WAIT /LOW %COMSPEC% /U /C "CHCP 65001 & %COMSPEC% /U /C "START "" /B /WAIT /D "\\?\%src%" zpaq64 a "%archivePath%" * -m3 2^>^>"%errorLog%" ^| tee -a "%stdoutLog%" ^|^| START "" "%errorLog%"""
    EXIT /B
)
rem START "%src% -> u:\Backups\V_Various" /D "\\?\%src%" /LOW %COMSPEC% /U /C "CHCP 65001 & %COMSPEC% /U /C "zpaq64 a "u:\Backups\V_Various\%archiveName%.zpaq" * -m3 2>>"u:\Backups\V_Various\%archiveName%.errors.log" | tee -a "u:\Backups\V_Various\%%~nxA.log"""