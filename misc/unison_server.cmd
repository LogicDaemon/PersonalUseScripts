@REM coding:CP866
CALL _unison_get_command.cmd
CHCP 65001 & %unisontext% -socket 10355 %*
