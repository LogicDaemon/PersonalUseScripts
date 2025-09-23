@(REM coding:CP866
REM ;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET "prefix=%~1"
SET "outDir=%~2"
IF NOT DEFINED outDir SET "outDir=%~dp0"
)
@(
    IF NOT "%outDir:~-1%"=="\" SET "outDir=%outDir%\"
    FOR /D %%A IN ("%prefix%-*.*") DO @CALL :AppendDir "%%~A"
)
@(
    "%LocalAppData%\Programs\7-max\7maxc.exe" -t zpaq64 a "%outDir%\%prefix%.m4.zpaq" %dirs% -m4 2>>"%outDir%\%prefix%.m4.zpaq.log"
    EXIT /B
)
:AppendDir
@(
    SET "dirs=%dirs% %*"
    EXIT /B
)
