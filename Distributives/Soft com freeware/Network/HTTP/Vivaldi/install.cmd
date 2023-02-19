@(REM coding:CP866
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "%~dp0Vivaldi.*.x64.exe"`) DO (
        "%~dp0%%~A" --vivaldi-silent --do-not-launch-chrome
        TASKKILL /F /IM "update_notifier.exe"
        REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Vivaldi Update Notifier" /d "" /t REG_SZ /f
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Vivaldi Update Notifier" /d "" /t REG_SZ /f
        EXIT /B
    )
)
