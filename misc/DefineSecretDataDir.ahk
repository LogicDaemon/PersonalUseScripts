;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

RegRead secretDataDir, HKEY_CURRENT_USER\Environment, SecretDataDir
If (InStr(secretDataDir, "%"))
    secretDataDir := ExpandEnvVars(secretDataDir)
FileSelectFolder secretDataDir, *%secretDataDir%, 3, Select secret data directory
If (ErrorLevel || !secretDataDir)
    ExitApp 1

secretDataDirUpper := Format("{:U}", secretDataDir)

For _, varName in [ "LocalAppData"
                  , "AppData"
                  , "ProgramData"
                  , "UserProfile"
                  , "SystemRoot"
                  , "ProgramFiles"
                  , "ProgramFiles(x86)"
                  , "CommonProgramFiles"
                  , "CommonProgramFiles(x86)" ] {
    EnvGet var, %varName%
    varUpper := Format("{:U}", var)
    If (varUpper = secretDataDirUpper) {
        secretDataDir := "%" varName "%"
        break
    }
    If StartsWith(secretDataDirUpper, varUpper) {
        secretDataDir := "%" varName "%" SubStr(secretDataDir, StrLen(var)+1)
        break
    }
}

RegWrite REG_EXPAND_SZ, HKEY_CURRENT_USER\Environment, SecretDataDir, %secretDataDir%
EnvUpdate
Exit

#include <ExpandEnvVars>
