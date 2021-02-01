@(REM coding:CP866

rem CALL "%~dp0ramdisk_dynamic.cmd"
rem imdisk -a -m %rd% -t vm -f "%ProgramData%\imdisk\imdisk_ramdisk.img" -o fix,hd
rem imdisk -a -m %rd% -t vm -f "d:\RAMDisk.img" -o fix,hd

imdisk -a -t vm -s 4G -m R: -o fix,hd -p "/fs:ntfs /q /y"
CALL "%~dp0CreateTempDirs on RAM-drive.cmd"
)
