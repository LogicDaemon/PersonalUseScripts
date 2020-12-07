@(REM coding:CP866
REM wget_the_site script
REM downloads and archives a site for viewing offline
REM uses wget and 7-zip
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED srcpath (
    ECHO Без указания srcpath скрипт не работает. srcpath --- это расположение папки для загрузки, она же папка с архивом
    EXIT /B 1
)
IF DEFINED RARopts ECHO Переменная RARopts определена, но не работает в этой версии скрипта! Используйте %%noarchmasks%% чтобы указать маски файлов для исключения их архива.>&2 & EXIT /B 1
IF DEFINED RARmoredirs ECHO Переменная RARmoredirs определена, но не работает в этой версии скрипта! Используйте %%moreDirs%%.>&2 & EXIT /B 1

SET "sitename=%~1"
IF "%~2"=="" (
  SET "URL=http://%sitename%/"
) ELSE SET "URL=%~2"
IF NOT DEFINED wgetcommonopt SET "wgetcommonopt=-m -w 2 --random-wait --waitretry=300 -x -E -e robots=off -k -K -p -np --no-check-certificate --progress=dot:giga"
REM %3 and further may be used to spec additional argiments, like
REM -X"dir1,dir2" - directory exclusion
REM -w N  -  wait N seconds between pages
REM -nd, --no-directories           don't create directories.
REM -x,  --force-directories        force creation of directories.
REM -nH, --no-host-directories      don't create host directories.
REM      --protocol-directories     use protocol name in directories.
REM -P,  --directory-prefix=PREFIX  save files to PREFIX/...
REM      --cut-dirs=NUMBER          ignore NUMBER remote directory components.
REM -c		### contunue downloading files
REM -a wget.log	### write all output to that log
REM -t 64	### 64 retries
REM -N		### use timestamping
REM -R,  --reject=LIST               comma-separated list of rejected extensions.
REM -H - host spanning
REM -D%* hosts to span across; when host spanning (-H) off, -D is meaningless

IF NOT DEFINED exe7z CALL find7zexe.cmd
IF NOT DEFINED wgetexe CALL findexe.cmd wgetexe wget.exe "%SystemDrive%\SysUtils\wget.exe"

CALL :parseMasks %noarchmasks%
)
(
    IF EXIST "%srcpath%%sitename%.7z" (
	%exe7z% x -aoa -o"%srcpath%" -- "%srcpath%%sitename%.7z"
    ) ELSE IF EXIST "%srcpath%%sitename%.rar" %exe7z% x -aoa -o"%srcpath%" -- "%srcpath%%sitename%.rar"

    SHIFT
    SHIFT
    START "" /b /wait /D"%srcpath%" wget.exe %wgetcommonopt% %URL% %1 %2 %3 %4 %5 %6 %7 %8 %9
    START "" /b /wait /D"%srcpath%" %exe7z% a -sdel -r %opts7z% -- "%sitename%.7z" "%sitename%" %moreDirs%

EXIT /B
)

:parseMasks <masks>
(
    IF "%~1"=="" EXIT /B
    SET opts7z=%opts7z% -xr!"%~1"
    SHIFT
GOTO :parseMasks
)
