@REM coding:OEM
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions

IF NOT DEFINED ErrorCmd (
    IF "%RunInteractiveInstalls%"=="1" (
        SET ErrorCmd=PAUSE
    ) ELSE (
        SET ErrorCmd=IF ERRORLEVEL 2 EXIT /B 2
    )
)

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%OOoBinDirectory%"=="" CALL _OOo_get_directories.cmd
IF "%OOoBinDirectory%"=="" CALL "%~dp0_corrections\_OOo_get_directories.cmd"
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles^(x86^)%
IF "%OOoBinDirectory%"=="" (
    SET OOoBinDirectory=%ProgramFiles%\OpenOffice.org 3\program\
)
SET unopkgexe=%OOoBinDirectory%unopkg
DEL "%OOoDirectory%share\extension\install\dict-ru.oxt"

REM install templates
REM 7z x -aoa "%srcpath%ooextras\extra_templates_ru.zip" -o"%OOoDirectory%share\template\ru\"
REM IF ERRORLEVEL 1 PAUSE
REM MKDIR "%OOoDirectory%share\template\ru\misc\"
REM copy "%srcpath%ooextras\eskd.ott" "%OOoDirectory%share\template\ru\misc\"
REM IF ERRORLEVEL 1 PAUSE

REM install addons
rem START "Installing Addons..." /LOW /B /WAIT 
CALL :addon_install "%srcpath%ooextras" cyrtools*.uno.zip
CALL :addon_install "%srcpath%ooextras" dict_ru_RU-*.oxt yes
CALL :addon_install "%srcpath%AddOns" 1Cxls-*.oxt
CALL :addon_install "%srcpath%AddOns" Pager-*.oxt
rem CALL :addon_install "%srcpath%AddOns" Pagination-*.oxt
rem CALL :addon_install "%srcpath%AddOns" CalcEasyToolbar-*.oxt
rem CALL :addon_install "%srcpath%AddOns" DateTime2-*.oxt

rem не устанавливается на OOo 3.3.0 i-RS CALL :addon_install "%srcpath%AddOns" StarXpert-autOOofilter-*.oxt

rem CALL :addon_install "%srcpath%Addons" "LanguageTool-*.oxt"
rem CALL :addon_install "%srcpath%AddOns" numbertext-*.oxt
rem CALL :addon_install "%srcpath%Addons" gdocs_*.oxt
rem CALL :addon_install "%srcpath%Addons" "sun-pdfimport-*.oxt" yes
rem CALL :addon_install "%srcpath%Addons" "oracle-presentation-minimizer-*.oxt" yes
rem CALL :addon_install "%srcpath%Addons" "Sun-Presentation-Minimizer_Win32Intel-*.oxt" yes

rem не устанавливается на OOo 3.3.0 i-RS CALL :addon_install "%srcpath%Addons" "svg-import-*.oxt" yes

EXIT /B

:addon_install
FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find %1 -name %2`) DO (
    IF "%~3"=="" (
	"%unopkgexe%" add --shared -v -f -s "%%~I"||%ErrorCmd%
    ) ELSE (
	ECHO %~3|"%unopkgexe%" add --shared -v -f -s "%%~I"||%ErrorCmd%
    )   
)

EXIT /B
