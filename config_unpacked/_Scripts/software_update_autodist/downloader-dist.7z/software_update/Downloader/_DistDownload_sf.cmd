@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

SET "distcleanup=1"

rem %1 project name http://sourceforge.net/projects/<name>
rem %2 file name mask

REM 32-bit
rem CALL "%~dp0_DistDownload.cmd" "http://sourceforge.net/projects/%~1/files/latest/download" %2 -m -l 1 -A "%~x2" -nd -H -D downloads.sourceforge.net -e "robots=off" -p --user-agent="Mozilla/5.0 (Windows NT 10.0; rv:0.0)"
REM 64-bit
CALL "%~dp0_DistDownload.cmd" "http://sourceforge.net/projects/%~1/files/latest/download" %2 -m -l 1 -A "%~x2" -nd -H -D downloads.sourceforge.net -e "robots=off" --trust-server-names --unlink -p --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

REM Alternate download way (if there's only windows version):
rem CALL "\Local_Scripts\software_update\Downloader\_DistDownload.cmd" http://sourceforge.net/projects/%1/files/latest/download %2 -N -A "%~x2"
)