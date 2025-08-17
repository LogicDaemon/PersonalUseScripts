@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS


SC STOP "DolbyDAXAPI"
SC STOP "LenovoVantageService"
SC CONFIG LenovoVantageService start= demand

SC STOP "TISmartAmpService"
SC CONFIG TISmartAmpService start= demand

SC STOP "NvBroadcast.ContainerLocalSystem"
SC CONFIG "NvBroadcast.ContainerLocalSystem" start= demand

SC STOP "igfxCUIService2.0.0.0"
SC CONFIG "igfxCUIService2.0.0.0" start= demand

SC STOP "igccservice"
SC CONFIG "igccservice" start= demand

SC STOP "InventorySvc"
SC CONFIG "InventorySvc" start= demand
)
