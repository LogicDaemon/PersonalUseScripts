FindScoopBaseDir() {
    Local
    Global JSON
    /*
    Based on the logic found in `lib/core.ps1`, Scoop determines its root directory using a specific precedence order. You can replicate this logic in an external script to locate the Scoop root without invoking the executable.

    ### Precedence Logic

    According to lines 1290-1291 of core.ps1, the root directory is determined in this order:

    1.  **Environment Variable**: Checks if `$env:SCOOP` is defined.
    2.  **Configuration File**: Checks the `root_path` property in the user's Scoop config file.
        *   Config location is determined by `$env:XDG_CONFIG_HOME` or defaults to `~/.config/scoop/config.json`.
    3.  **Default Location**: Falls back to `$env:USERPROFILE\scoop`.

    *(Note: core.ps1 also checks its own script location to support portable installs, but an external script cannot rely on that context).*
    */

    ; 1. Check Environment Variable
    EnvGet scoopRoot, SCOOP
    If (scoopRoot && FileExist(scoopRoot))
        Return scoopRoot

    ; 2. Check Configuration File
    EnvGet xdgConfigHome, XDG_CONFIG_HOME
    EnvGet UserProfile, USERPROFILE

    configFile := (xdgConfigHome ? xdgConfigHome : UserProfile "\.config") . "\scoop\config.json"

    If (FileExist(configFile)) {
        FileRead configRaw, %configFile%
        scoopRoot := JSON.Load(configRaw).root_path
        If (FileExist(scoopRoot))
                Return scoopRoot
    }

    ; 3. Default Location
    scoopRoot := UserProfile "\scoop"
    If (FileExist(scoopRoot))
        Return scoopRoot

    ; Fallback: Original logic
    EnvGet path, PATH
    For _, dir in StrSplit(path, ";") {
        dir := ExpandEnvVars(dir)
        If (FileExist(dir "\scoop.cmd") || FileExist(dir "\scoop.ps1")) {
            Loop Files, % dir "\..", D
                Return A_LoopFileLongPath
        }
    }
    Throw Exception("Scoop not found in PATH")
}

; MsgBox % "Found: " FindScoopBaseDir()
#include <ExpandEnvVars>
#Warn LocalSameAsGlobal, Off
#include <JSON>
