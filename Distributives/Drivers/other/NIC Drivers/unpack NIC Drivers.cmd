(
@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED dest SET "dest=d:\Distributives\Drivers_local\NIC"
)
"%~dp07za.exe" x -o"%dest%" -- "%~dp0NIC Drivers.7z"
