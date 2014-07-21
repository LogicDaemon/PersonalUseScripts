REM coding:OEM
ECHO Will be emptied and RO: %*
PAUSE

:next
DEL %1
TOUCH %1
ATTRIB +R %1

SHIFT
IF NOT "%~1"=="" GOTO :next
