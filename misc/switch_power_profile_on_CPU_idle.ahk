﻿;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
#SingleInstance Force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

OnExit(Func("ExitFunc"))

WatchCPU()

ExitApp

WatchCPU(measure_time_ms := 1000, idle_limit := 0.8, idle_count_to_switch_power_profile := 5) {
    local
    idle_count := 0
    last_scheme := 1
    skip_cycle := False
    GetIdleTime()
    Loop
    {
        Sleep measure_time_ms
        idle := GetIdleTime()
        If (skip_cycle) {
            skip_cycle := False
        } Else If (idle > idle_limit) {
            idle_count++
            If (idle_count > idle_count_to_switch_power_profile && last_scheme = 1)
                last_scheme := SetScheme(2)
        } Else {
            idle_count := 0
            If (last_scheme = 2)
                last_scheme := SetScheme(1)
        }
    }
}

SetScheme(idx) {
    local
    global SystemRoot
    ; 1 is normal
    ; 2 is low-freq
    static schemes := ["381b4222-f694-41f0-9685-ff5bb260df2e", "8d4b2d46-48b8-4712-b17d-2a7d9b70a76e"]
    schemeGUID := schemes[idx]
    
    RunWait %SystemRoot%\System32\powercfg.exe /SETACTIVE %schemeGUID%,, Hide
    return idx
}

ExitFunc(ExitReason, ExitCode) {
    local
    SetScheme(1)
    TrayTip,, Power scheme is set to normal
}

#include <GetIdleTime>
