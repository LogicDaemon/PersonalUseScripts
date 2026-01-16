;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

Process Exist, ollama.exe
If (ErrorLevel)
    ExitApp

SplitPath A_LineFile,, scriptDir, ext, scriptNameNoExt
FileRead vulkanHosts, %scriptDir%\%scriptNameNoExt%_vulkan_hosts.txt
RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
If (InStr(vulkanHosts "`r`n", hostname "`r`n") || InStr(vulkanHosts "`n", hostname "`n"))
    EnvSet OLLAMA_VULKAN, 1
EnvSet OLLAMA_ORIGINS, *
Run ollama serve,, Min UseErrorLevel
