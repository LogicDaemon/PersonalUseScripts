@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF NOT DEFINED ErrorCmd (
    IF NOT "%RunInteractiveInstalls%"=="0" (
        SET ErrorCmd=PAUSE
    ) ELSE (
        SET ErrorCmd=IF ERRORLEVEL 2 EXIT /B 2
    )
)

ECHO.
ECHO Common install procedure start
IF NOT DEFINED SELECT_WORD SET SELECT_WORD=0
IF NOT DEFINED SELECT_EXCEL SET SELECT_EXCEL=0
IF NOT DEFINED SELECT_POWERPOINT SET SELECT_POWERPOINT=0
ECHO SELECT_WORD=%SELECT_WORD%, SELECT_EXCEL=%SELECT_EXCEL%, SELECT_POWERPOINT=%SELECT_POWERPOINT%

ECHO Calling OOo_Install_sources_and_destinations.cmd
CALL "%srcpath%OOo_Install_sources_and_destinations.cmd"||EXIT /B

ECHO Copying _OOo_get_directories.cmd to "%scriptdir%"
MKDIR "%scriptdir%"
copy /Y "%srcpath%_corrections\_OOo_get_directories.cmd" "%scriptdir%\"||%ErrorCmd%
rem ECHO Adding "%scriptdir%" to PATH
rem "%utilsdir%pathman.exe" /as %scriptdir%||%ErrorCmd%
ECHO Calling "%scriptdir%\_OOo_get_directories.cmd"
CALL "%scriptdir%\_OOo_get_directories.cmd"||%ErrorCmd%

ECHO Extracting source archive to "%OOoTempDir%"
7z.exe x -aoa "%OOoSourceArchive%" -o"%OOoTempDir%"||%ErrorCmd%
FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find "%OOoTempDir%" -name "%MSIMask%"`) DO SET OOoMSIFile=%%~I
IF NOT DEFINED OOoMSIFile FOR %%I IN ("%OOoTempDir%\%MSIMask%") DO SET OOoMSIFile=%%~fI
IF NOT DEFINED OOoMSIFile %ErrorCmd%

ECHO Starting MSI install
REM 2.4 version switches: SELECT_WORD=%SELECT_WORD% SELECT_EXCEL=%SELECT_EXCEL% SELECT_POWERPOINT=%SELECT_POWERPOINT% 
PUSHD "%OOoTempDir%"
FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" SET WinVer=2K& SET WinVerNum=5.0
IF "%WinVer:~0,22%"=="Microsoft Windows XP [" SET WinVer=XP& SET WinVerNum=5.1
IF "%WinVer:~0,27%"=="Microsoft Windows [Version " SET WinVerNum=%WinVer:~27,-1%
IF "%WinVer:~0,26%"=="Microsoft Windows [Версия " SET WinVerNum=%WinVer:~26,-1%
IF NOT DEFINED WinVerNum SET WinVerNum=?

@ECHO ON
IF %WinVerNum:~0,3% GEQ 6.0 (
    setup.exe /qn||%ErrorCmd%
    GOTO :SkipMSIExec
)
msiexec.exe /qn /norestart /i "%OOoMSIFile%" INSTALLLOCATION="%OOoDirectory%" COMPANYNAME="Цифроград-Ставрополь" ADDLOCAL=ALL REMOVE=gm_o_Testtool,gm_o_Xsltfiltersamples,gm_o_Quickstart,gm_o_Pyuno||@%ErrorCmd%
@ECHO OFF
:SkipMSIExec
POPD

IF "%SetSystemSettings%"=="1" (
    ECHO Associating with filetypes...
    CALL "%srcpath%\OpenOffice.org.associations.cmd"
)

ECHO Removeing "%OOoTempDir%"
RD /s /q "%OOoTempDir%"||%ErrorCmd%

ECHO Optionally installing defaults
CALL "%srcpath%\OOo_Install_SetDefaults.cmd"

ECHO Calling OOo_Install_addons_and_extras.cmd
CALL "%srcpath%\OOo_Install_addons_and_extras.cmd"

ECHO Common install procedure end
ENDLOCAL
