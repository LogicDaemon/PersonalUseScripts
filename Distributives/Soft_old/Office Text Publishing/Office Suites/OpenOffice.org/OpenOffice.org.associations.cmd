@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED ErrorCmd (
    IF NOT "%RunInteractiveInstalls%"=="0" (
        SET ErrorCmd=PAUSE
    ) ELSE (
        SET ErrorCmd=
    )
)

IF NOT DEFINED OOoexecfile CALL _OOo_get_directories.cmd
IF NOT DEFINED OOoexecfile CALL "%SystemDrive%\Local_Scripts\_OOo_get_directories.cmd"
IF NOT DEFINED OOoexecfile %ErrorCmd% & EXIT /B 2

rem org:	.xls=Excel.Sheet.8
rem org:	.xlsx=Excel.Sheet.12
IF NOT "%SELECT_EXCEL%"=="0"		CALL :CheckAndAssiciate .ods .xls .xlsx
IF NOT "%SELECT_WORD%"=="0"		CALL :CheckAndAssiciate .odt .doc .docx 
IF NOT "%SELECT_POWERPOINT%"=="0"	CALL :CheckAndAssiciate .odp .ppt .pps .pptx .ppsx
EXIT /B
:CheckAndAssiciate
    FOR /F "usebackq delims== tokens=1*" %%I IN (`ASSOC %1`) DO SET FTYPE=%%J
    IF NOT DEFINED FTYPE EXIT /B 1
    IF "%FTYPE%"=="" EXIT /B 1
:NextExtension
    SHIFT
    IF %1.==. EXIT /B
rem     FOR /F "usebackq tokens=1 delims==" %%I IN (`assoc %1`) DO IF "%%I"=="%1" EXIT /B 1
    ASSOC %1=%FTYPE%
GOTO :NextExtension
