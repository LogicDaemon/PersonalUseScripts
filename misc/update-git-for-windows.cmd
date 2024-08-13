@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    rem "%LocalAppData%\Programs\Git\git-bash.exe" --hide --no-needs-console --command=cmd\git.exe update-git-for-windows --quiet --gui
    rem git update-git-for-windows -y
    taskkill /f /im git.exe
    scoop update git
    IF EXIST "%LOCALAPPDATA%\Programs\Git\etc\gitconfig" (
        DEL "%LOCALAPPDATA%\Programs\scoop\apps\git\current\etc\gitconfig.bak" 2>NUL
        REN "%LOCALAPPDATA%\Programs\scoop\apps\git\current\etc\gitconfig" gitconfig.bak
        MKLINK /H "%LOCALAPPDATA%\Programs\scoop\apps\git\current\etc\gitconfig" "%LOCALAPPDATA%\Programs\Git\etc\gitconfig"
    )
    PUSHD "%LOCALAPPDATA%\Programs\scoop\shims" && (
        DFHL.exe /r /l /o .
        POPD
    )
)
