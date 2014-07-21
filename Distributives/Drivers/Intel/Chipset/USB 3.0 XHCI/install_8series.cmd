@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
(
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
)
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg
IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe=""
IF NOT EXIST %AutohotkeyExe% CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\FindAutoHotkeyExe.cmd" || EXIT /B

%AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srcpath%8, 9, C220, C610 Series\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_3.0.1.41.zip"
