@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem podman machine init
podman machine start
wsl -d podman-machine-default -- sudo bash -c 'printf "\nnameserver 10.9.0.10\nnameserver 10.232.65.10\nnameserver 172.31.16.1\nnameserver 1.1.1.1\n" ^>^> /etc/resolv.conf'
)
