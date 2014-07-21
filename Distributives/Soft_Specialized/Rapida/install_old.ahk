#NoEnv

RunWait 7zg x -o"%A_Temp%" "%A_ScriptDir%\soft.rapida.ru\download\pmsetup\pm_download.php" PMSetup.exe
RunWait "%A_Temp%\PMSetup.exe"
FileDelete "%A_Temp%\PMSetup.exe"

FileCopyDir \\AcerAspire7720G\Projects\Рапида\PaymMaster,d:\Program Files\Rapida\PaymMaster,1
RunWait install.cmd,d:\Program Files\Rapida\PaymMaster
