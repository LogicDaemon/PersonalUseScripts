;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

Process Exist, ollama.exe
If (!ErrorLevel) {
    EnvSet OLLAMA_ORIGINS, *
;    EnvSet OLLAMA_VULKAN, 1
    Run ollama serve,, Min UseErrorLevel
}
