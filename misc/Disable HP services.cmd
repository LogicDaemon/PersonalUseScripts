@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

	REM hpatchmon - already manual
	FOR %%A IN ( ^
		HPAppHelperCap ^
		HPAudioAnalytics ^
		HPDiagsCap ^
		HpTouchpointAnalyticsService ^
		LanWlanWwanSwitchingServiceUWP ^
		HPNetworkCap ^
		hpsvcsscan ^
		HPSysInfoCap ^
	) DO @(
		sc config %%A start= demand
		sc stop %%A
	)
)
