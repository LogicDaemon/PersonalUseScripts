@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

SCHTASKS /Change /TN "Microsoft\Windows\Application Experience\MareBackup" /Disable
SCHTASKS /Change /TN "Microsoft\Windows\Hotpatch\Monitoring" /Disable

SC STOP edgeupdatem
SC STOP edgeupdate
SC CONFIG edgeupdatem start= demand
SC CONFIG edgeupdate start= demand

@REM SC STOP "DolbyDAXAPI"

FOR %%A IN ( ^
	"TISmartAmpService" ^
	"igfxCUIService2.0.0.0" ^
	"igccservice" ^
	"InventorySvc" ^
	"NvBroadcast.ContainerLocalSystem" ^
	"NvContainerLocalSystem" ^
	HPAppHelperCap ^
	HPAudioAnalytics ^
	HPDiagsCap ^
	HotKeyServiceUWP ^
	HpTouchpointAnalyticsService ^
	LanWlanWwanSwitchingServiceUWP ^
	HPNetworkCap ^
	hpsvcsscan ^
	HPSysInfoCap ^
) DO @(
	SC STOP "%%~A"
	SC CONFIG "%%~A" start= demand
)

CALL "%~dp0Disable Lenovo services.cmd"
