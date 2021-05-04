@rem coding:CP866

cd /d "%PROGRAMFILES(X86)%\Microsoft\Edge\Application\8*\Installer" || PAUSE
rem setup.exe --uninstall --force-uninstall --system-level
setup.exe --uninstall --msedge --system-level
rem  --verbose-logging
