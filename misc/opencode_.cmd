@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

	IF NOT DEFINED PROJECT_DIR SET "PROJECT_DIR=%CD%"
	SET "ARGS=%*"

	CALL "%~dp0podman_start.cmd"
)
@SET "PROJECT_DIR=%PROJECT_DIR:~,-1%"
@(
	SET "HOME=%USERPROFILE:\=/%"
	SET "ARGS=%ARGS:\=/%"
	SET "PROJECT_DIR=%PROJECT_DIR:\=/%"
)
@(
	SET "HOME=%HOME:C:=/mnt/c%"
	SET "ARGS=%ARGS:C:=/mnt/c%"
	SET "PROJECT_DIR=%PROJECT_DIR:C:=/mnt/c%"
)
@(
	SET "HOME=%HOME:D:=/mnt/d%"
	SET "ARGS=%ARGS:D:=/mnt/d%"
	SET "PROJECT_DIR=%PROJECT_DIR:D:=/mnt/d%"
)
podman run -it --rm ^
	-v "opencode-settings:/root/.local" ^
	-v "%HOME%/.gitconfig:/root/.gitconfig" ^
	-v "%HOME%/.git-credentials:/root/.git-credentials" ^
	-v "%PROJECT_DIR%:/workspace" ^
	-w "/workspace" ^
	--pull newer ^
	ghcr.io/anomalyco/opencode %*
