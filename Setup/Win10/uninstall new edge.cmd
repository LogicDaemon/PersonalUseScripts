@rem coding:CP866

cd /d "%PROGRAMFILES(X86)%\Microsoft\Edge\Application\8*\Installer" || PAUSE
setup.exe --uninstall --force-uninstall --system-level
