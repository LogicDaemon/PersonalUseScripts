@echo off
sc config wuauserv start= auto
sc start wuauserv
PUSHD "%~dp0cmd"
CALL DoUpdate /nobackup /updatetsc /instofccnvs %*
POPD
rem sc config wuauserv start= manual
