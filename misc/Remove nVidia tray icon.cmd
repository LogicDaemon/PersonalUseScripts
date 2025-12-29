@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

sc.exe stop NvContainerLocalSystem
sc.exe config NvContainerLocalSystem start= disabled
)
