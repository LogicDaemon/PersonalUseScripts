@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS

    IF "%~2"=="" (
        ECHO Usage: %~nx0 start_time meeting_ID [schedule] [task_name]
        ECHO.
        ECHO        start_time      local date and time in 24h format. For example, 11:58
        ECHO        meeting_ID      Meeting URL or part after anymeeting.com/
        ECHO                        ^(will get anymeeting://anymeeting.com/ prefix^).
        ECHO                        ex: kkuznetsova or https://anymeeting.com/kkuznetsova
        ECHO        schedule        Optional. Arguments for /SC, see schtasks /create /?
        ECHO                        Quote whole string if it contains spaces.
        ECHO                        Defaults: "WEEKLY /D MON,TUE,WED,THU,FRI"
        ECHO                        Use empty quotes ^(""^) if you want to specify task name
        ECHO                        with the default schedule.
        ECHO                        Might include /MO difiers.
        ECHO                        Valid values for the /MO switch per schedule type:
        ECHO                            MINUTE:  1 - 1439 minutes.
        ECHO                            HOURLY:  1 - 23 hours.
        ECHO                            DAILY:   1 - 365 days.
        ECHO                            WEEKLY:  weeks 1 - 52.
        ECHO                            ONCE:    No modifiers.
        ECHO                            ONSTART: No modifiers.
        ECHO                            ONLOGON: No modifiers.
        ECHO                            ONIDLE:  No modifiers.
        ECHO                            MONTHLY: 1 - 12, or
        ECHO                                     FIRST, SECOND, THIRD, FOURTH, LAST, LASTDAY.
        ECHO        task_name       Optional. Name of the task in the scheduler.
        ECHO                        By default, it's meeting_URL with time and schedule.
        EXIT /B
    )
    SET "start_time=%~1"

    SET "meeting_URL=%~2"

    SET "schedule=%~3"
    IF NOT DEFINED schedule SET "schedule=WEEKLY /D MON,TUE,WED,THU,FRI"

    IF "%~4"=="" (
        CALL :MakeValidFilename task_name "%~2 %~1 %~3"
    ) ELSE (
        CALL :MakeValidFilename task_name "%~4"
    )
)
@IF "%meeting_URL:://=%"=="%meeting_URL%" (
    SET "meeting_CMD=\"%%LOCALAPPDATA%%\Programs\Intermedia Unite\Intermedia Unite.exe\" anymeeting://anymeeting.com/%~2"
) ELSE (
    SET "meeting_CMD=\"%%ProgramFiles%%\Google\Chrome\Application\chrome.exe\" %meeting_URL%"
)
@(
    ECHO task_name: %task_name%
    ECHO start_time: %start_time%
    ECHO schedule: %schedule%
    ECHO Meeting URL: %meeting_URL%
    ECHO Command: %meeting_CMD%
)
SCHTASKS /Create /ST %1 /TN "Unite Meetings\%task_name%" /TR "%meeting_CMD%" /RU "%USERDOMAIN%\%USERNAME%" /IT /SC %schedule%
@EXIT /B
:MakeValidFilename <varname> <time>
@(
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "v=%~2"
    SET "v=!v::=_!"
    SET "v=!v:/=_!"
    SET "v=!v:\=_!"
)
@(
    ENDLOCAL
    SET "%~1=%v%"
EXIT /B
)
