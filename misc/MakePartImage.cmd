@(REM coding:CP866
    SET "fs=%~3"
    IF NOT DEFINED fs SET "fs=FAT32"
    SET "src=%~1"
    IF NOT DEFINED src SET /P "src=source image: "
    SET "dst=%~2"
)
IF NOT DEFINED dst CALL :setDst "%src%"
(
    FOR /F "usebackq delims=" %%A IN (`DIR /AD /O-D /B "%LOCALAPPDATA%\Programs\Easy2Boot_MPI\*.*"`) DO (
        set AUTORUN=Y
        CALL "%LOCALAPPDATA%\Programs\Easy2Boot_MPI\%%~A\MakePartImage.cmd" %src% %dst% %fs% *
        EXIT /B
    )
    EXIT /B
)
:setDst <src>
(
    IF "%src:~0,2%"=="\\" ( SET "dst=%TEMP%\%~nx1.imgPTN" ) ELSE SET "dst=%~dpn1.imgPTN"
EXIT /B
)
