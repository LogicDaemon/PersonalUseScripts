@(REM coding:CP866
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "%~dp0Vivaldi.*.x64.exe"`) DO (
        "%~dp0%%~A" --vivaldi-silent --do-not-launch-chrome
        EXIT /B
    )
)
