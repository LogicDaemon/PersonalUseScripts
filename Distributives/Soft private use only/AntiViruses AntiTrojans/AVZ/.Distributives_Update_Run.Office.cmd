SET srcpath=%~dp0
CALL \Scripts\_DistDownload.cmd http://z-oleg.com/avz4.zip avz4.zip -N --progress=dot:giga -o avz4.zip-download.log
CALL \Scripts\_DistDownload.cmd http://z-oleg.com/avz_se.zip avz_se.zip -N --progress=dot:giga -o avz_se.zip-download.log
CALL \Scripts\_DistDownload.cmd http://z-oleg.com/secur/avz_up/avzbase.zip avzbase.zip -N --progress=dot:giga -o avzbase.zip-download.log
