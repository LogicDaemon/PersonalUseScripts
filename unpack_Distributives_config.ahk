;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

#include <find7zexe>

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

backupWorkingDir := A_WorkingDir
unpackDir = %A_ScriptDir%\Distributives\config_unpacked
SetWorkingDir %A_ScriptDir%\Distributives\config
Loop Files, *.7z, R
    RunPooled(exe7z " x -y -aoa -o""" unpackDir ".tmp\" A_LoopFileFullPath """ -- """ A_LoopFileLongPath """", {options: "Hide"})
RunPooled("", {drain: true})
SetWorkingDir %backupWorkingDir%
FileRemoveDir %unpackDir%, 1
FileMoveDir %unpackDir%.tmp, %unpackDir%, R
ExitApp

RunPooled(ByRef command_line, ByRef runOptions := "") {
    static procCountLimit := 0, running := {}
    
    If (runOptions.drain) {
        procCountLimit := 0
    } Else If (procCountLimit == 0) {
        EnvGet procCountLimit, NUMBER_OF_PROCESSORS
        procCountLimit--
    }
    
    Loop
    {
        processes := ProcessList()
        For ppid in running {
            If (!processes.HasKey(ppid))
                running.Delete(ppid)
        }
        
        If (running.Count() <= procCountLimit) {
            break
        } Else {
            Sleep 300
        }
    }
    
    If (command_line) {
        Run %command_line%, % runOptions.dir, % runOptions.options, ppid
        running[ppid] := command_line
    }
}

#include <ProcessList>
