@REM coding:OEM
SET srcpath=%~dp0

START "" /D"%srcpath%" /B /WAIT wget -N http://download.sysinternals.com/Files/SysinternalsSuite.zip
SET RARopts=-x*.zip
CALL wget_the_site.cmd live.sysinternals.com
