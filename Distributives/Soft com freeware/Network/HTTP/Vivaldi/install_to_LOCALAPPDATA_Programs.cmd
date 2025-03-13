@(REM coding:CP866
SET runPrefix=
SET runSuffix=
%SystemRoot%\System32\fltmc.exe >nul 2>&1 && (
    SET "runPrefix=CALL FindAutoHotkeyExe.cmd "%LOCALAPPDATA%\Scripts\nprivRun.ahk" %comspec% /C ""
    SET "runSuffix=""
)
)
%runPrefix%"%~dp0install.cmd" --vivaldi-install-dir="%LOCALAPPDATA%\Programs\Vivaldi"%runSuffix%
