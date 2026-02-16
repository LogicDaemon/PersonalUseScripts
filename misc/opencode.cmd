@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

IF NOT EXIST "%LocalAppData%\Temp_" MKDIR "%LocalAppData%\Temp_"
SET "TMP=%LocalAppData%\Temp_"
SET "TEMP=%LocalAppData%\Temp_"
opencode.exe %*
)
