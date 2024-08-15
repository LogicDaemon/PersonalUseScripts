@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
robocopy "d:\Distributives" "%~dp0Distributives" *.cmd *.ahk *.list descript.ion "partial list of free SysUtils.txt" jre_install_common.cfg opabackup342.exe.config /S /XD config Drivers_local Local_Scripts LLMs Soft_local wsusoffline /XF *.lnk

REM ln --unroll --recursive --mirror "%USERPROFILE%\Documents\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib"
robocopy "%USERPROFILE%\Documents\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib" /MIR /S
REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
@REM ln --excludedir .mypy_cache --excludedir connect-asg-host --excludedir helper_shortcuts --excludedir Photo --excludedir temp-backup-scripts --excludedir software_update --exclude Hotkeys_Custom.ahk --exclude Hotkeys_Custom.*.ahk --exclude *.lnk --exclude _Distributives.base_dirs.txt --exclude aws_s.cmd --exclude aws_t.cmd --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts" "%~dp0misc"
@REM ln --unroll --recursive --mirror "%LOCALAPPDATA%\Scripts\Lib" "%~dp0misc\Lib"
@REM ln --unroll --recursive --mirror "%LOCALAPPDATA%\Scripts\.vscode" "%~dp0misc\.vscode"
@REM ln --excludedir old --exclude *.lnk --exclude "Copy photos from flash cards.destinations.txt" --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo"
robocopy "%LOCALAPPDATA%\Scripts" "%~dp0misc" /MIR /S /XD .mypy_cache .venv connect-asg-host helper_shortcuts Photo temp-backup-scripts software_update /XF Hotkeys_Custom.ahk Hotkeys_Custom.*.ahk *.lnk _Distributives.base_dirs.txt aws_s.cmd aws_t.cmd
robocopy "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo" /MIR /S /XD old /XF *.lnk "Copy photos from flash cards.destinations.txt"
CALL "%~dp0update.finalize.cmd"
)
