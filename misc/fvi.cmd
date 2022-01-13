@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF EXIST "%LOCALAPPDATA%\Programs\FreeVimager\FreeVimager.exe" (
    START "" /B "%LOCALAPPDATA%\Programs\FreeVimager\FreeVimager.exe" %*
    EXIT /B
)
IF DEFINED ProgramFiles^(x86^) (
    SET "lProgramFiles=%ProgramFiles(x86)%"
) ELSE (
    SET "lProgramFiles=%ProgramFiles%"
)
START "" /B "%lProgramFiles%\FreeVimager\FreeVimager.exe" %*
