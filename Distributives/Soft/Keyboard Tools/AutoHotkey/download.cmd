@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
@(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
)
@(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    
    rem CALL :DownloadDistributive https://autohotkey.com/download/ahk.zip "AutoHotkey_*.zip"
    CALL :DownloadDistributive https://autohotkey.com/download/ahk.zip "*.zip"
    rem CALL :DownloadDistributive https://autohotkey.com/download/ahk-install.exe "AutoHotkey_*_setup.exe"
    CALL :DownloadDistributive https://autohotkey.com/download/ahk-install.exe "*.exe"
    RD /Q "%workdir%"
    EXIT /B
)
:DownloadDistributive
(
    SETLOCAL
    SET "url=%~1"
    SET "urlfname=%~nx1"
    SET "distfmask=%~2"
)
IF NOT DEFINED distfmask SET "distfmask=%urlfname%"
CALL :GetExt expected_ext "%distfmask%"
FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%srcpath%%distfmask%"`) DO (
    SET "curDistPath=%srcpath%%%~A"
    SET "curDistName=%%~nxA"
    REM on 2022 and years before, any -z condition causes 0-sized file to be downloaded
    SET timeCond=-z "%srcpath%%%~A"
    GOTO :ExitFor_CurDistPath
)
:ExitFor_CurDistPath
(
    MKDIR "%workdir%new.tmp"
    FOR %%A IN ("J" "") DO (
        REM -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.80 Safari/537.36"
        REM -H "accept-encoding: gzip, deflate, br" ^
        REM -H "accept-language: en-GB,en-US;q=0.9,en;q=0.8" ^
        REM -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3" ^
        REM -H "upgrade-insecure-requests: 1" ^
        curl -LRO%%~A ^
            %timeCond% ^
            --output-dir "%workdir%new.tmp" ^
            --remove-on-error ^
            --path-as-is ^
            -H "authority: autohotkey.com" ^
            -- "%url%"
        REM on 2022 and years before, any -z condition causes 0-sized file to be downloaded
        FOR %%B IN ("%workdir%new.tmp\*.*") DO @IF "%%~zB"=="0" DEL "%%~B"
        rem without -o for CURL and -O for wget, filename is unknown
        FOR %%D IN ("%workdir%new.tmp\*%expected_ext%") DO (	
            ECHO Checking %%~nxD
            SET "dlfname=%%~nxD"
            SET "ver="
            CALL :GetFileVer ver "%%~D" || CALL :GetVerFromName ver "%%~D"
            
            IF "%%~nxD"=="%urlfname%" (
                IF DEFINED ver (
                    CALL :ReplaceStarWithStr dstfname "%distfmask%" "%ver%"
                ) ELSE (
                    ECHO Could not determine version of "%%~nxD", and it's used to define filename
                )
            )
            IF NOT DEFINED dstfname SET "dstfname=%%~nxD"
            CALL :PrintDstFname
            IF DEFINED ver GOTO :ExitGetVerLoop
        )
    )
    
    IF NOT DEFINED dlfname CALL :ExitWithError Nothing downloaded & EXIT /B 1
)
:ExitGetVerLoop
(
    IF NOT "%ver%"=="" ( REM when destination is on a remote, somehow ver is defined but is empty string
        IF NOT "%ver:~0,2%"=="1." (
	    ( CALL :ExitWithError "Version %ver% downloaded from %url% (must be version 1.*), aborting"
	    EXIT /B 1
	    ) > "%srcpath%warning.txt"
        )
        ( ECHO %ver%	%dstfname%
        ) > "%srcpath%newver%expected_ext%.txt"
        CALL :movedst "%workdir%new.tmp\%dlfname%" && MOVE /Y "%srcpath%newver%expected_ext%.txt" "%srcpath%ver%expected_ext%.txt"
    ) ELSE IF "%dlfname%"=="%dlfname:_1.=%" IF "%dlfname%"=="%dlfname: 1.=%" (
        CALL :ExitWithError "Unknown version (file name %dlfname%) downloaded from %url%, aborting"
	EXIT /B 1
    ) >> "%srcpath%warning.txt"
    
    RD /Q "%workdir%new.tmp"
EXIT /B 0
)
:movedst
(
    SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
    CALL "%baseScripts%\DistCleanup.cmd" "%srcpath%%distfmask%" "%srcpath%%dstfname%"
    IF EXIST "%srcpath%%dstfname%" COMP %1 "%srcpath%%dstfname%" /M >NUL && EXIT /B
    MOVE /Y %1 "%srcpath%%dstfname%"
EXIT /B
)
:ExitWithError
(
    ECHO [!!!] %DATE% %TIME% Error: %*
    RD "%workdir%new.tmp"
EXIT /B
)
:GetFileVer <varname> <path>
@(
    SETLOCAL
    SET "fileNameForWMIC=%~2"
)
@SET "fileNameForWMIC=%fileNameForWMIC:\=\\%"
(
    FOR /F "usebackq skip=1" %%I IN (`wmic datafile where Name^="%fileNameForWMIC%" get Version`) DO @(
        REM IF NOT "%%~I"=="" does not work here, it's always unequal, but it looks like there's \n or something nasty is in the loop var
        REM it works after assigning to the env var though
        SET "verWMIC=%%~I"
        CALL :GetFileVerCheckEmpty tmp_ver && GOTO :GetFileVer_done
    )
)
:GetFileVer_done
@(
    ENDLOCAL
    IF "%tmp_ver%"=="" EXIT /B 1
    SET "%~1=%tmp_ver%"
    EXIT /B
)
:GetVerFromName <varname> <path>
(
    SETLOCAL
    REM name example: AutoHotkey_1.1.34.03.zip
    FOR /F "delims=_ tokens=2" %%I IN ("%~n2") DO @IF NOT "%%~I"=="" (
        ENDLOCAL
        SET "%~1=%%~I"
        EXIT /B 0
    )
    EXIT /B 1
)
:GetFileVerCheckEmpty
@(
    ENDLOCAL
    IF NOT "%verWMIC%"=="" (
        SET "%~1=%verWMIC%"
        EXIT /B 0
    )
    EXIT /B 1
)

:GetExt <var> <path>
@(
    SET "%~1=%~x2"
    EXIT /B
)
:ReplaceStarWithStr <varname> <str_with_a_star> <replacement>
@(
    FOR /F "tokens=1* delims=*" %%A IN (%2) DO SET "%~1=%%~A%~3%%~B"
    EXIT /B
)
