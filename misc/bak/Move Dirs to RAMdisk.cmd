@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
	@REM SET "vscodeRemoteWSLDistSubdir=Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code Addons\Remote Server\vscode-remote-wsl"
	@REM CALL "%~dp0_Distributives.find_subpath.cmd" Distributives "%vscodeRemoteWSLDistSubdir%"
	@REM IF DEFINED Distributives IF EXIST %Distributives%\%vscodeRemoteWSLDistSubdir% SET "vscodeRemoteWSLDist=%Distributives%\%vscodeRemoteWSLDistSubdir%"
	"%LocalAppData%\Programs\bin\UpdateRamdiskLinks.exe" "%~dp0ramdisk-config.yaml"
	EXIT /B
)
