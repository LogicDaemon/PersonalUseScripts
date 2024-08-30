@(REM coding:CP866
robocopy %* ^
	*.cmd *.ahk *.list *.py descript.ion "partial list of free SysUtils.txt" ^
	jre_install_common.cfg opabackup*.exe.config ^
	/S /XD .mypy_cache .venv config Drivers_local LLMs Local_Scripts ^
	Soft_local "Soft malicious" ^
	wsusoffline Images
)
