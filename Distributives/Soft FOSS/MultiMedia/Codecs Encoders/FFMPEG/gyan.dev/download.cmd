@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

START "" /D "%~dp0" wget -N https://www.gyan.dev/ffmpeg/builds/ffmpeg-tools.zip
START "" /D "%~dp0" wget -pr -ml1 -A.html,.7z https://www.gyan.dev/ffmpeg/builds/
)
