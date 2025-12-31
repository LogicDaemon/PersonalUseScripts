@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

IF "%~3" NEQ "" (
    ECHO Usage: "%~nx0" input.json [output.json]
    EXIT /B 1
)
SET "out=%~2"
IF NOT DEFINED out SET "out=%~1"
)
py -c "import json; json.dump(json.load(open('%~1', 'rb')), open('%out%', 'w', newline='\n'), sort_keys=True, indent=4, ensure_ascii=False)"
