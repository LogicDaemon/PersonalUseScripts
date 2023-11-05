@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
robocopy "d:\Distributives" "%~dp0Distributives" *.cmd *.ahk *.list *.py descript.ion "partial list of free SysUtils.txt" jre_install_common.cfg opabackup342.exe.config /S /XD config Drivers_local Local_Scripts wsusoffline

ln --unroll --recursive --mirror "%USERPROFILE%\Documents\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib"
@REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
rem -x --exclude
rem -X --excludedir
ln -X .mypy_cache -X connect-asg-host -X helper_shortcuts -X Photo -X temp-backup-scripts -X software_update -x Hotkeys_Custom.ahk -x Hotkeys_Custom.*.ahk -x *.lnk -x _Distributives.base_dirs.txt -x aws_s.cmd -x aws_t.cmd --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts" "%~dp0misc"
ln --unroll --recursive --mirror "%LOCALAPPDATA%\Scripts\.vscode" "%~dp0misc\.vscode"
ln --excludedir old -x *.lnk -x "Copy photos from flash cards.destinations.txt" --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo"
CALL "%~dp0update.finalize.cmd"
)
