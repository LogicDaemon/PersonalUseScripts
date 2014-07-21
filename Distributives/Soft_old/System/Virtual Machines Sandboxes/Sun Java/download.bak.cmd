@REM coding:OEM
SET srcpath=%~dp0

SET aria2cOpt=-Z -R -j1 -s1 --http-no-cache=false --enable-http-pipelining=true --use-head=true --no-conf --file-allocation=none --disable-ipv6

CALL :singleDownload "http://javadl.sun.com/webapps/download/AutoDL?BundleId=45824" "JRE\Windows X32 Offline"

EXIT /B

:singleDownload
    SETLOCAL

    SET URI=%~1
    REM relative outputdir; if empty, must be backslash; shout not end with backslash otherwise
    SET outputdir=%~2
    IF "%outputdir%"=="" SET outputdir=.
    

    SET preDlFileList=%TEMP%\%outputdir:\=_%-preDownload.list
    SET DlLog=%TEMP%\%outputdir:\=_%-download.log
    SET DlErrLog=%~dp0download.errors.log

    REM IF NOT EXIST "%preDlFileList%" DIR /B "%~dp0%outputdir%">"%preDlFileList%"
    aria2c %aria2cOpt% -d"%~dp0%outputdir%" "%URI%" 2>>"%DlErrLog%" 1>"%DlLog%"||EXIT /B %ERRORLEVEL%
    REM FOR %%I IN ("%~dp0%outputdir%") DO 

    FOR /F "usebackq tokens=2,4 delims=|" %%I IN ("%DlLog%") DO IF "%%~I"=="OK"
    
    REM gid|stat|avg speed  |path/URI
    REM ===+====+===========+==========================================================
    REM   1|  OK|       0B/s|X:\Distributives\Soft\System\Virtual Machines Sandboxes\Sun Java\JRE\Windows X32 Offline/jre-6u19-windows-i586-s.exe

    REM DEL "%preDlFileList%"

EXIT /B


REM Aria 2 command line options
REM -j, --max-concurrent-downloads=N	Set maximum number of parallel downloads for every static (HTTP/FTP) URI, torrent and metalink. See also -s and -C option. Default: 5
REM -d, --dir=DIR	The directory to store the downloaded file.
REM -R, --remote-time[=true|false]	REM Retrieve timestamp of the remote file from the remote HTTP/FTP server and if it is available, apply it to the local file. Default: false
REM -s, --split=N	Download a file using N connections. If more than N URIs are given, first N URIs are used and remaining URIs are used for backup. If less than N URIs are given, those URIs are used more than once so that N connections total are made simultaneously. Please see -j option too. Please note that in Metalink download, this option has no effect and use -C option instead. Default: 5
REM -D, --daemon	Run as daemon. The current working directory will be changed to / and standard input, standard output and standard error will be redirected to /dev/null. Default: false
REM --log-level=LEVEL	Set log level to output. LEVEL is either debug, info, notice, warn or error. Default: debug
REM --on-download-complete=COMMAND	Set the command to be executed when download completes. See --on-download-start option for the requirement of COMMAND. See also --on-download-stop option. Possible Values: /path/to/command
REM --on-download-error=COMMAND	Set the command to be executed when download aborts due to error. See --on-download-start option for the requirement of COMMAND. See also --on-download-stop option. Possible Values: /path/to/command 
REM --on-download-start=COMMAND	Set the command to be executed when download starts up. COMMAND must take just one argument and GID is passed to COMMAND as a first argument. Possible Values: /path/to/command
REM --on-download-stop=COMMAND	Set the command to be executed when download stops. You can override the command to be executed for particular download result using --on-download-complete and --on-download-error. If they are specified, command specified in this option is not executed. See --on-download-start option for the requirement of COMMAND. Possible Values: /path/to/command 
REM --summary-interval=SEC	Set interval in seconds to output download progress summary. Setting 0 suppresses the output. Default: 60
REM -Z, --force-sequential[=true|false]	Fetch URIs in the command-line sequentially and download each URI in a separate session, like the usual command-line download utilities. Default: false
REM -q, --quiet[=true|false]	Make aria2 quiet (no console output). Default: false
REM --stop=SEC	Stop application after SEC seconds has passed. If 0 is given, this feature is disabled. Default: 0
REM EXIT STATUS
REM Because aria2 can handle multiple downloads at once, it encounters lots of errors in a session. aria2 returns the following exit status based on the last error encountered.
REM 0	If all downloads are successful. 
REM 1	If an unknown error occurs. 
REM 2	If time out occurs. 
REM 3	If a resource is not found. 
REM 4	If aria2 sees the specfied number of "resource not found" error. See --max-file-not-found option). 
REM 5	If a download aborts because download speed is too slow. See --lowest-speed-limit option) 
REM 6	If network problem occurs. 
REM 7	If there are unfinished downloads. This error is only reported if all finished downloads are successful and there are unfinished downloads in a queue when aria2 exits by pressing Ctrl-C by an user or sending TERM or INT signal.
REM Note	An error occurred in a finished download will not be reported as exit status.
REM --check-certificate[=true|false]	Verify the peer using certificates specified in --ca-certificate option. Default: true
