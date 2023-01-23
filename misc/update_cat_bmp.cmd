@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
PUSHD "%TEMP%" || EXIT /B
FOR /F "usebackq delims=" %%A IN (`curl -H "x-api-key: f5417adf-ca32-4d64-9182-55e9f8beb018" https://api.thecatapi.com/v1/images/search ^| jq ".[0].url"`) DO curl -RL "%%~A" -o cat.jpg
"%LocalAppData%\Programs\ImageMagick\mogrify.exe" -format bmp cat.jpg
)
