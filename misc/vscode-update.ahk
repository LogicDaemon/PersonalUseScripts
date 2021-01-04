#NoEnv
EnvGet SystemRoot, SystemRoot
EnvGet LocalAppData, LocalAppData
distDir = %LocalAppData%\Programs\VSCode_distributive
themePath = %distDir%\VSCode_dark_theme.7z
destBaseDir = %LocalAppData%\Programs
destPath = %LocalAppData%\Programs\VS Code
lastID := "8795a9889db74563ddd43eb0a897a2384129a619" ; 1.40.1

#include <find7zexe>

Try {
    updCheck := JSON.Load(GetURL("https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/" lastID))
    ; {"url":"https://az764295.vo.msecnd.net/stable/f359dd69833dd8800b54d458f6d37ab7c78df520/VSCode-win32-x64-1.40.2.zip","name":"1.40.2","version":"f359dd69833dd8800b54d458f6d37ab7c78df520","productVersion":"1.40.2","hash":"7c33d0ec7dec6b23d64bb209316bc07c5ba0ebaf","timestamp":1574693656541,"sha256hash":"1b2311c276cbee310e801b4d6a9e0cd501ee35e66c55db4d728d15a6a4ada033","supportsFastUpdate":true}
    If (updCheck.version != lastID) {
        newVerURL := updCheck.url
        SplitPath newVerURL, dlName
        FileCreateDir %distDir%
        RunWait %SystemRoot%\System32\curl.exe -RO -z "%distDir%\%dlName%" "%newVerURL%", %distDir%, Min UseErrorLevel
        newVerName := updCheck.name
        RunWait "%exe7z%" x -aoa -o"%destPath%.%newVerName%" -- "%distDir%\%dlName%"
        RunWait "%exe7z%" x -aoa -o"%destPath%.%newVerName%" -- "%themePath%"
        RunWait %comspec% /C "RD "%destPath%" & MKLINK /J "%destPath%" "%destPath%.%newVerName%""
    }
} catch e {
    Throw e
}
ExitApp

#include <GetURL>
#include <JSON>
