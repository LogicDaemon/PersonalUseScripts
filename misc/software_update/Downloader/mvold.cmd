@REM coding:OEM
:next
    FOR %%I IN ("%~1") DO CALL :mvold "%%~I"
    SHIFT
    IF NOT "%~1"=="" GOTO :next

EXIT /B

:mvold
    SETLOCAL
    SET destination=%~1
    SET destination=%destination:\Distributives\=\Distributives\_old\%
    CALL :mkpath "%destination%"
    ECHO Moving "%~1" to "%destination%"
    MOVE "%~1" "%destination%"
    ENDLOCAL
EXIT /B

REM Subprocedure required to be able to apply %~dp transformation (applicable only to numbered arguments)
REM Typical error message:
REM 	The following usage of the path operator in batch-parameter
REM 	substitution is invalid: %~dp transformation (applicable only to numbered arguments)
:mkpath
    IF NOT EXIST "%~dp1" MKDIR "%~dp1"
EXIT /B
