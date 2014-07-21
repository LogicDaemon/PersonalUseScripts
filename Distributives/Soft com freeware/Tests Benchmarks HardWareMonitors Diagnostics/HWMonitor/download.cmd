@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" ftp://ftp.cpuid.com/hwmonitor/ hwmonitor_* -m -np
CALL wget_the_site www.cpuid.com http://www.cpuid.com/softwares/hwmonitor.html
