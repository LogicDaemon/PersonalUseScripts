;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

distDir=d:\Distributives\Soft com freeware\MultiMedia\Codecs\codecguide.com\K-Lite Codec Pack
distGlob=K-Lite_Codec_Pack_*_Standard.exe
distPathGlob=%distDir%\%distGlob%
;flagPath=%LocalAppData%\LogicDaemon\Distributives\klcp.txt
If (!FileExist(distPathGlob))
	ExitApp 1

;FileReadLine installerVerDistName, %flagPath%, 1
RegRead instVer, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\KLCodecPack, base_version
;instVer=1968

latestVerDistName := latestTS := ""
Loop Files, %distPathGlob%
{
	If (A_LoopFileTimeModified > latestTS) {
		latestTS := A_LoopFileTimeModified
		, latestVerDistName := A_LoopFileName
	}
}
;latestVerDistName=K-Lite_Codec_Pack_1968_Standard.exe
latestVerPos := RegExMatch(latestVerDistName, "\d+", latestVer)

;If (latestVer == installerVerDistName)
If (latestVer == instVer)
	ExitApp 0

;flagTmp=%flagPath%.tmp
;t := FileOpen(flagTmp, "w")
;t.WriteLine(latestVerDistName)
;Try {
	RunWait %comspec% /C klcp_standard_unattended.cmd, %distDir%, Min UseErrorLevel
;} Catch e {
;	t.WriteLine("Error " e.Message "`t" e.What "`t" e.Extra)
;}
;If (e:=ErrorLevel)
;	t.WriteLine("Error #" ErrorLevel)
;t.Close()
;If (!e)
;	FileMove %flagTmp%, %flagPath%, 1
