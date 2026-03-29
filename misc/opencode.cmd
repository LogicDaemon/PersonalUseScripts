@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

IF NOT EXIST "%LocalAppData%\Temp" MKDIR "%LocalAppData%\Temp"
SET "TMP=%LocalAppData%\Temp"
SET "TEMP=%LocalAppData%\Temp"
IF /I "%CD%"=="%WINDIR%\System32" (
    MKDIR "%USERPROFILE%\Documents\Temp"
    CD /D "%USERPROFILE%\Documents\Temp"
)
IF NOT EXIST "%TEMP%\opencode-prefix.txt" (
    REM a separate window to avoid changing the console font prematurely
    START "" /MIN /WAIT powershell.exe -c "scoop prefix opencode >"${Env:TEMP}\opencode-prefix.txt""
)
IF EXIST "%TEMP%\opencode-prefix.txt" FOR /F "usebackq delims=" %%P IN ("%TEMP%\opencode-prefix.txt") DO @IF EXIST "%%P\opencode.exe" (
    START "" /B "%%P\opencode.exe" %*
    EXIT /B
)
START "" /B opencode.exe %*
)
