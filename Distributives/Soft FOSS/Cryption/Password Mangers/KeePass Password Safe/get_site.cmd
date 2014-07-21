@REM coding:OEM
SET srcpath=%~dp0
SET RARopts=-x*.zip -x*.exe -x*.7z -x*.rar -x*.xpi -x*.msi -x*.u3p -x*.plg -x*.plgx
CALL wget_the_site keepass.info
IF NOT EXIST "%~dp0keepass.info\extensions" EXIT /B

SET srcpath=%~dp0keepass.info\extensions
CALL wget_the_site gogogadgetscott.info http://gogogadgetscott.info/keepass/twofishcipher/ http://gogogadgetscott.info/keepass/titledisplay/
CALL wget_the_site www.gbuffer.net http://www.gbuffer.net/kxch
CALL wget_the_site www.aliasbailbonds.com http://www.aliasbailbonds.com/KeeForm/item/keeform-a-form-filler-for-keepass
CALL wget_the_site keefox.org
CALL wget_the_site pwm2keepass.sourceforge.net
rem CALL wget_the_site sourceforge.net https://sourceforge.net/projects/pronouncepwgen/ https://sourceforge.net/projects/keepass-favicon/
CALL wget_the_site rdc-keepass-plugin.appspot.com
