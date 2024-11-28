;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData, LOCALAPPDATA
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
laPrograms := LocalAppData "\Programs"

win11minversion := "10.0.22000"
autohotkeyHelp := VerCompare(A_OsVersion, ">=" win11minversion)
                ? "https://www.autohotkey.com/docs/v1/"
                : FirstExisting( A_AhkDir "\AutoHotkey.chm"
                               , laPrograms "\AutoHotkey\AutoHotkey.chm"
                               , A_ProgramFiles "\AutoHotkey\AutoHotkey.chm" )
Run "%autohotkeyHelp%"

; https://www.libe.net/en-windows-build
; Windows 11 versions:
;version	discovered
;22H2 (Build: 22621.1344)	2023-03-01
;22H2 (Build: 22621.1265)	2023-02-15
;22H2 (Build: 22621.1194)	2023-01-27
;22H2 (Build: 22621.1105)	2023-01-10
;22H2 (Build: 22621.963)	2022-12-14
;22H2 (Build: 22621.900)	2022-11-30
;22H2 (Build: 22621.819)	2022-11-09
;22H2 (Build: 22621.755)	2022-10-27
;22H2 (Build: 22621.675)	2022-10-19
;22H2 (Build: 22621.674)	2022-10-12
;22H2 (Build: 22621.608)	2022-10-01
;22H2 (Build: 22621.525)	2022-09-29
;22H2 (Build: 22621.521)	2022-09-27
;21H2 (Build: 22000.978)	2022-09-14
;21H2 (Build: 22000.918)	2022-08-26
;21H2 (Build: 22000.856)	2022-08-10
;21H2 (Build: 22000.832)	2022-07-22
;21H2 (Build: 22000.795)	2022-07-13
;21H2 (Build: 22000.778)	2022-06-24
;21H2 (Build: 22000.740)	2022-06-21
;21H2 (Build: 22000.739)	2022-06-15
;21H2 (Build: 22000.708)	2022-05-25
;21H2 (Build: 22000.675)	2022-05-11
;21H2 (Build: 22000.652)	2022-04-26
;21H2 (Build: 22000.613)	2022-04-14
;21H2 (Build: 22000.593)	2022-03-29
;21H2 (Build: 22000.556)	2022-03-09
;21H2 (Build: 22000.527)	2022-02-16
;21H2 (Build: 22000.493)	2022-02-08
;21H2 (Build: 22000.469)	2022-01-26
;21H2 (Build: 22000.438)	2022-01-18
;21H2 (Build: 22000.434)	2022-01-12
;21H2 (Build: 22000.376)	2021-12-14
;21H2 (Build: 22000.348)	2021-11-26
;21H2 (Build: 22000.318)	2021-11-10
;21H2 (Build: 22000.282)	2021-11-08
;21H2 (Build: 22000.194)	2021-10-06

; Windows 10 versions:
;version	discovered
;22H2 (Build: 19045.2673)	2023-02-22
;22H2 (Build: 19045.2604)	2023-02-15
;22H2 (Build: 19045.2546)	2023-01-24
;22H2 (Build: 19045.2486)	2023-01-11
;22H2 (Build: 19045.2364)	2022-12-14
;22H2 (Build: 19045.2311)	2022-11-16
;22H2 (Build: 19045.2251)	2022-11-09
;22H2 (Build: 19045.2130)	2022-10-19
;21H2 (Build: 19044.2130)	2022-10-12
;21H2 (Build: 19044.2075)	2022-09-21
;21H2 (Build: 19044.2006)	2022-09-14
;21H2 (Build: 19044.1949)	2022-08-27
;21H2 (Build: 19044.1889)	2022-08-10
;21H2 (Build: 19044.1865)	2022-07-27
;21H2 (Build: 19044.1826)	2022-07-13
;21H2 (Build: 19044.1806)	2022-06-29
;21H2 (Build: 19044.1767)	2022-06-21
;21H2 (Build: 19044.1766)	2022-06-15
;21H2 (Build: 19044.1741)	2022-06-03
;21H2 (Build: 19044.1708)	2022-05-20
;21H2 (Build: 19044.1706)	2022-05-11
;21H2 (Build: 19044.1682)	2022-04-26
;21H2 (Build: 19044.1645)	2022-04-14
;21H2 (Build: 19044.1620)	2022-03-23
;21H2 (Build: 19044.1586)	2022-03-09
;21H2 (Build: 19044.1566)	2022-02-16
;21H2 (Build: 19044.1526)	2022-02-08
;21H2 (Build: 19044.1503)	2022-01-26
;21H2 (Build: 19044.1469)	2022-01-19
;21H2 (Build: 19044.1466)	2022-01-12
;21H2 (Build: 19044.1415)	2021-12-15
;21H2 (Build: 19044.1387)	2021-11-23
;21H2 (Build: 19044.1288)	2021-11-18
;21H1 (Build 19043)	2021-05-19
;20H2 (Build 19042)	2020-10-20
;2004 (Build 19041)	2020-05-27
;1909 (Build 18363)	2019-11-12
;1903 (Build 18362)	2019-03-21
;1809 (Build 17763)	2018-11-13
;1803 (Build 17134)	2018-04-30
;1709 (Build 16299)	2017-10-17
;1703 (Build 15063)	2017-04-05
;1607 (Build 14393)	2016-08-02
;1511 (Build 10586)	2015-11-10
;1507 (Build 10240)	2015-07-29
