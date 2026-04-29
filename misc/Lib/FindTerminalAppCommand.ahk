FindTerminalAppCommand() {
	Local
	Global LocalAppData
	Static scoopDir
	IF (!scoopDir)
		scoopDir := FindScoopBaseDir()
	If (FileExist(weztermexe := scoopDir "\apps\wezterm\current\wezterm-gui.exe")) {
		r = "%weztermexe%" start --
	} Else If (FileExist(alacritty := scoopDir "\apps\alacritty\current\alacritty.exe")) {
		r = "%alacritty%" -e
	} Else {
		If (!LocalAppData)
			EnvGet LocalAppData,LOCALAPPDATA
		If (FileExist(wtexe := LocalAppData "\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe")) {
			r = "%wtexe%" new-tab
		}
	}
	Return r
}

If (A_ScriptFullPath == A_LineFile) {
	MsgBox % FindTerminalAppCommand()
}

#include %A_LineFile%\..\FindScoopBaseDir.ahk
