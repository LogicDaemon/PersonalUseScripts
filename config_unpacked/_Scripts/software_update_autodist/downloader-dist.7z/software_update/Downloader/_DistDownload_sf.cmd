@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

SET "distcleanup=1"

rem %1 project name http://sourceforge.net/projects/<name>
rem %2 file name mask

rem user agents: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent/Firefox

REM 32-bit
rem backup user agent: Mozilla/5.0 (Windows NT 10.0; rv:0.0)
CALL "%~dp0_DistDownload.cmd" "http://sourceforge.net/projects/%~1/files/latest/download" %2 -m -l 1 -A "%~x2" -nd -H -D sourceforge.net,downloads.sourceforge.net -e "robots=off" --trust-server-names --unlink -p --user-agent="Wget/1.19.1 (mingw32)"
REM 64-bit
rem backup user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
CALL "%~dp0_DistDownload.cmd" "http://sourceforge.net/projects/%~1/files/latest/download" %2 -m -l 1 -A "%~x2" -nd -H -D sourceforge.net,downloads.sourceforge.net -e "robots=off" --trust-server-names --unlink -p --user-agent="Wget/1.19.1 (mingw64)"

REM Alternate download way (if there's only windows version):
rem CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/%1/files/latest/download %2 -N -A "%~x2"
)
