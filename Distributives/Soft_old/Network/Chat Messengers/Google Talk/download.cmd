@REM coding:OEM
IF NOT EXIST "%~dp0temp" MKDIR "%~dp0temp"
START "" /B /WAIT /D"%~dp0" wget -N http://dl.google.com/googletalk/googletalk-setup.exe http://dl.google.com/googletalk/googletalk-setup-ru.exe http://dl.google.com/googletalk/googletalk-setup-en-GB.exe -o "%~dp0temp\%~n0.log"
