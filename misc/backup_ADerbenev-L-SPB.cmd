@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

SET "destBase=d:\Users\LogicDaemon\My SecuriSync"
SET "mssDir=%USERPROFILE%\My SecuriSync"
)
(
    CHCP 65001
    robocopy "%SystemRoot%\System32\Tasks" "%mssDir%\config\Tasks" /MIR /ZB /EFSRAW /DCOPY:DAT /R:3 /NP /TEE /UNILOG:"%mssDir%\config\Tasks.log"

    IF EXIST "%destBase%.zpaq.log" MOVE "%destBase%.zpaq.log" "%destBase%.zpaq.log.bak"
    IF NOT EXIST "%destBase%.zpaq.log" START "" /D "\\?\%mssDir%" /LOW /B zpaq.exe a "%destBase%.zpaq" "\\?\%mssDir%" -m5 -not "\\?\%mssDir%\.SecuriSync" -summary 0 2>&1 | tee -a "%destBase%.zpaq.log"

    FOR %%A IN ("%LocalAppData%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\*.json") DO ^
        xln "%%~A" "%USERPROFILE%\My SecuriSync\Backups\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\%%~nxA"
)
