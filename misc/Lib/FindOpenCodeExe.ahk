FindOpenCodeExe() {
	Local
	Global LocalAppData
	If (!LocalAppData)
		EnvGet LocalAppData,LOCALAPPDATA
	temp=%LocalAppData%\Temp
	EnvSet TMP, %temp%
	EnvSet TEMP, %temp%
		
	Loop
	{
		FileReadLine opencodePrefix, %temp%\opencode-prefix.txt, 1
		If (opencodePrefix)
			Break
		RunWait powershell.exe -c "scoop prefix opencode >"${Env:TEMP}\opencode-prefix.txt"", %temp%, Min
	} Until A_LoopIndex>1

	r = "%opencodePrefix%\opencode.exe"
	Return r
}
