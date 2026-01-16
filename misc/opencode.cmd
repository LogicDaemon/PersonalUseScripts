@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0podman_start.cmd"
wezterm start podman start -ia opencode ^
|| wezterm start podman run --name opencode -v /root/.local -it ghcr.io/anomalyco/opencode
)
