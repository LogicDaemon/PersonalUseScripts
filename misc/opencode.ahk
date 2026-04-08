#NoEnv
EnvGet LocalAppData,LOCALAPPDATA

scoopDir := FindScoopBaseDir()
If (FileExist(weztermexe := scoopDir "\apps\wezterm\current\wezterm-gui.exe")) {
	termApp = "%weztermexe%" start --
} Else If (FileExist(alacritty := scoopDir "\apps\alacritty\current\alacritty.exe")) {
	termApp = "%alacritty%" -e
} Else If (FileExist(wtexe := LocalAppData "\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe")) {
	termApp = "%wtexe%" new-tab
}

temp=%LocalAppData%\Temp
EnvSet TMP, %temp%
EnvSet TEMP, %temp%

If (A_WorkingDir = A_WinDir "\System32") {
	FileCreateDir %A_MyDocuments%\Temp
	SetWorkingDir %A_MyDocuments%\Temp
}

Loop
{
	FileReadLine opencodePrefix, %temp%\opencode-prefix.txt, 1
	If (opencodePrefix)
		Break
	RunWait powershell.exe -c "scoop prefix opencode >"${Env:TEMP}\opencode-prefix.txt"", %temp%, Min
} Until A_LoopIndex>1

Run %termApp% "%opencodePrefix%\opencode.exe"
ExitApp

#include <FindScoopBaseDir>
