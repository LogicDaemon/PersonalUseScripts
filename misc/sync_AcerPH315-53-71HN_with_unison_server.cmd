@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
@IF NOT DEFINED syncprog ( SET "syncprog=%unisontext%" ) ELSE IF NOT DEFINED filterSyncs IF NOT [%unisontext%]==[%syncprog%] SET "filterSyncs=1"
@(
    rem "%LocalAppData%\Programs\msys64\ucrt64.exe" 
    SET "PATH=%LocalAppData%\Programs\msys64\usr\bin;%PATH"

    %unisontext% "Distributives_autosync_paths@AcerPH315-53-71HN" ^
        -root "%unisonServer%v:/Distributives" ^
        -prefer "%unisonServer%v:/Distributives" -auto -batch
    
    IF DEFINED filterSyncs IF NOT "%filterSyncs%"=="0" (
        ECHO Checking for changes
        <NUL %unisontext% "Distributives@u327016.your-storagebox.de" -root "%unisonServer%v:/Distributives" -auto=false && (
            ECHO No changes, exiting
            PING 127.0.0.1 >NUL
            EXIT /B
        )
    ) ELSE (
        rem ECHO Synchronizing Soft and drivers without updates
        rem %unisontext% Distributives_u327016.your-storagebox.de %unisonopt% -noupdate -batch -path Soft -path Drivers -path "Soft com freeware" -path "Soft com license" -path "Soft FOSS" -path "Soft private use only" %unisonServer%v:/Distributives
        rem -noupdate is ineffective, and rsync will add new files anyway
    )
    ECHO Starting full sync with manual confirmation
    %syncprog% "Distributives@u327016.your-storagebox.de" -root "%unisonServer%v:/Distributives" %unisonopt%
)
