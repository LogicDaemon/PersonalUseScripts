@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

REG ADD "HKEY_CURRENT_USER\Software\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}" /ve /d "7-Zip Shell Extension" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /ve /d "%LocalAppData%\Programs\7-Zip\7-zip.dll" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\CLSID\{23170F69-40C1-278A-1000-000100020000}\InprocServer32" /v "ThreadingModel" /d "Apartment" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\7-Zip" /ve /d "{23170F69-40C1-278A-1000-000100020000}" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\Directory\shellex\ContextMenuHandlers\7-Zip" /ve /d "{23170F69-40C1-278A-1000-000100020000}" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\Folder\shellex\ContextMenuHandlers\7-Zip" /ve /d "{23170F69-40C1-278A-1000-000100020000}" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\Directory\shellex\DragDropHandlers\7-Zip" /ve /d "{23170F69-40C1-278A-1000-000100020000}" /f
REG ADD "HKEY_CURRENT_USER\Software\Classes\Drive\shellex\DragDropHandlers\7-Zip" /ve /d "{23170F69-40C1-278A-1000-000100020000}" /f
REG ADD "HKEY_CURRENT_USER\SOFTWARE\7-Zip\Options" /v "MenuIcons" /t REG_DWORD /d 00000001
REG ADD "HKEY_CURRENT_USER\SOFTWARE\7-Zip\Options" /v "CascadedMenu" /t REG_DWORD /d 00000001
)
