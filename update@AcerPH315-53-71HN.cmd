@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
rem START "" /B %comspec% /C "%~dp0update_Distributives_scripts.cmd" "v:\Distributives" "%~dp0Distributives"

ln --unroll --recursive --mirror "%USERPROFILE%\Documents\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib"
ln --excludedir bin --excludedir PlugIns --excludedir reg --unroll --recursive --mirror  "%USERPROFILE%\Dropbox\Projects\LocalAppData\Programs\Total Commander" "%~dp0Total Commander"
@REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
rem -x --exclude
rem -X --excludedir
ln -X .mypy_cache -X .venv -X connect-asg-host -X helper_shortcuts -X Photo -X temp-backup-scripts -X software_update -X Soft_old -x Hotkeys_Custom.ahk -x Hotkeys_Custom.*.ahk -x *.lnk -x _Distributives.base_dirs.txt -x aws_s.cmd -x aws_t.cmd --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts" "%~dp0misc"
ln --unroll --recursive --mirror "%LOCALAPPDATA%\Scripts\.vscode" "%~dp0misc\.vscode"
ln --excludedir old -x *.lnk -x "Copy photos from flash cards.destinations.txt" --unroll --recursive --mirror  "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo"
)
