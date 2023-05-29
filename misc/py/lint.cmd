@(
IF NOT "%~1"=="" PUSHD %1 || EXIT /B
START "" /B %comspec% /C "py -m prospector -AX"
START "" /B %comspec% /C "py -m mypy ."
rem Not working on Windows
rem START "" /B %comspec% /C "py -m pytype ."
)
