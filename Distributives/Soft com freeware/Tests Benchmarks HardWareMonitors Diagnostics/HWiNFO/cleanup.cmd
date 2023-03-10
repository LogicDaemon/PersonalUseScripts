@REM coding:OEM
SET selfname=%~dpnx0
FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "-!!! cleanup list-" "%selfname%"`) DO SET skiplines=%%I
FOR /F "usebackq skip=%skiplines% delims=" %%I IN ("%selfname%") DO (
    DEL "%%~I"
    touch "%%~I"
    ATTRIB +R "%%~I"
)

EXIT /B

REM -!!! cleanup list-
hw32_436.zip
hw32_438.zip
hw32_440.zip
hw32_442.zip
hw32_444.zip
hw32_446.zip
hw32_448.zip
hw32_450.zip
hw32_451_2415.zip
hw32_451_2441.zip
hw32_451_2444.zip
hw32_451_2450.zip
hw32_460.zip
hw32_461_2465.zip
hw32_461_2470.zip
hw32_461_2476.zip
hw32_461_2480.zip
hw32_462.zip
hw32_463_2510.zip
hw32_463_2515.zip
hw32_463_2520.zip
hw32_464.zip
hw32_465_2533.zip
hw32_465_2540.zip
hw32_465_2545.zip
hw64_436.zip
hw64_438.zip
hw64_440.zip
hw64_442.zip
hw64_444.zip
hw64_446.zip
hw64_448.zip
hw64_450.zip
hw64_451_2415.zip
hw64_451_2441.zip
hw64_451_2444.zip
hw64_451_2450.zip
hw64_460.zip
hw64_461_2465.zip
hw64_461_2470.zip
hw64_461_2476.zip
hw64_461_2480.zip
hw64_462.zip
hw64_463_2510.zip
hw64_463_2515.zip
hw64_463_2520.zip
hw64_464.zip
hw64_465_2533.zip
hw64_465_2540.zip