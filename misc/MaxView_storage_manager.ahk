#NoEnv

EnvGet SystemRoot,SystemRoot
RunWait %SystemRoot%\System32\schtasks.exe /Run /TN "LogicDaemon\maxview_tasks_start",, Min
Run https://localhost:8443/maxview/manager/login.xhtml
