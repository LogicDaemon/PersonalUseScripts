@REM coding:OEM
SET srcpath=%~dp0
SET RARopts=-x*.zip -x*.exe

wget_the_site.cmd www.acc.umu.se http://www.acc.umu.se/~bosse/ -np
