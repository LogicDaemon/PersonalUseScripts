START "" /B /WAIT /D"%~dp0" wget -nv -N http://go.trendmicro.com/free-tools/hijackthis/HiJackThis.exe -o "%~dpn0.log" && DEL "%~dpn0.log"
