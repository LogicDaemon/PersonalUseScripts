;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

libreOfficeDL := RegexMatch( GetUrl("https://www.libreoffice.org/download/download/")
                           , "href=""//download\.documentfoundation\.org/libreoffice/stable/(?P<dirVer>[0-9.]+)/win/(?P<dirArch>x[0-9_]+)/LibreOffice_(?P<nameVer>[0-9.]+)_Win_(?P<nameArch>x\d+)\.msi\.torrent"""
                           , m)

;MsgBox % "dirArch: " mdirArch
;       . "`ndirVer: " mdirVer
;       . "`nnameVer: " mnameVer
;       . "`nnameArch: " mnameArch

RunWait %comspec% /C "%A_ScriptDir%\download_ver.cmd" %mnameVer%,, UseErrorLevel
Exit %ErrorLevel%
