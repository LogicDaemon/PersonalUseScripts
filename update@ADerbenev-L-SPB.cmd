(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
ln --unroll --recursive --mirror "%USERPROFILE%\Documents\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib"
@REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
ln --excludedir .mypy_cache --excludedir connect-asg-host --excludedir helper_shortcuts --excludedir Photo --excludedir temp-backup-scripts --excludedir software_update --exclude Hotkeys_Custom.ahk --exclude Hotkeys_Custom.*.ahk --exclude KeePass_*.ahk --exclude *.lnk --exclude _Distributives.base_dirs.txt --exclude aws_s.cmd --exclude aws_t.cmd --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts" "%~dp0misc"
ln --unroll --recursive --mirror "%LOCALAPPDATA%\Scripts\.vscode" "%~dp0misc\.vscode"
ln --excludedir old --exclude *.lnk --exclude "Copy photos from flash cards.destinations.txt" --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo"
CALL "%~dp0update.finalize.cmd"
)
