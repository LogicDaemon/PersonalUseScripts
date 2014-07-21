@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
SET srcpath=%~dp0

IF NOT EXIST ooextras MKDIR ooextras
PUSHD ooextras
REM http://extensions.services.openoffice.org/ru/node/3234
wget -N http://extensions.services.openoffice.org/e-files/3233/0/dict_ru_RU-0.3.4.oxt
POPD

