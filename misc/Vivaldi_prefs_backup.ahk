﻿#NoEnv

RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
EnvGet LocalAppData, LocalAppData

FilesToCopy := {  "Bookmarks": ""
                , "Calendar": ""
                , "Contacts": ""
                , "contextmenu.json": ""
                , "Custom Dictionary.txt": ""
                , "Notes": ""
                , "Preferences": ""
                , "Secure Preferences": ""
                , "Shortcuts": ""
                , "Web Data": "" }

ExceptionDirs := { "System Profile": ""
                , "Guest Profile": "" }
Try destDir := GetDropboxDir(false) "\Config\@" hostname "\Vivaldi\User Data\"
Catch {
    ExitApp 1
}

Try SetWorkingDir % LocalAppData "\Vivaldi\User Data"
Catch e {
    Throw e
}

Loop Files, *.*, D
{
    If (!ExceptionDirs.HasKey(A_LoopFileName)) {
        For fname in FilesToCopy {
            If (FileExist(relPath := A_LoopFileFullPath "\" fname)) {
                SplitPath relPath,, relDir
                If (prevDir != relDir) {
                    prevDir := relDir
                    FileCreateDir %destDir%%prevDir%
                }
                FileCopy %relPath%, %destDir%%relPath%, 1
            }
        }
    }
}

ExitApp

#include <GetDropboxDir>
