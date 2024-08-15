@(REM coding:CP866
wsl "bash" "-c" "cd $HOME ; echo 'Press Enter to connect jumpnets'; read; while ! .local/bin/proxy; do sleep 3; done; while ! .local/bin/proxycdn; do sleep 3; done"
)
