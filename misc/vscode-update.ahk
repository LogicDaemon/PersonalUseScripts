#NoEnv
EnvGet SystemRoot, SystemRoot
EnvGet LocalAppData, LocalAppData
distDir = d:\Distributives\Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code
themePath = %distDir%\VSCode_dark_theme.7z
destBaseDir = %LocalAppData%\Programs
destPath = %destBaseDir%\VS Code
verfile = %distDir%\lastID.txt

FileCreateDir %distDir%
FileRead lastUpdCheckRaw, %verfile%
lastID := lastUpdCheckRaw ? JSON.Load(lastUpdCheckRaw).version : "8795a9889db74563ddd43eb0a897a2384129a619" ; 1.40.1
;"ea3859d4ba2f3e577a159bc91e3074c5d85c0523" ; 1.52.1

Try {
    updCheckRaw := GetURL("https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/" lastID)
    If (!updCheckRaw)
        Exit 1
    updCheck := JSON.Load(updCheckRaw)
    If (!updCheck.version)
        Throw Exception("Version request has not returned GUID",, updCheckRaw)
    ; {"url":"https://az764295.vo.msecnd.net/stable/f359dd69833dd8800b54d458f6d37ab7c78df520/VSCode-win32-x64-1.40.2.zip","name":"1.40.2","version":"f359dd69833dd8800b54d458f6d37ab7c78df520","productVersion":"1.40.2","hash":"7c33d0ec7dec6b23d64bb209316bc07c5ba0ebaf","timestamp":1574693656541,"sha256hash":"1b2311c276cbee310e801b4d6a9e0cd501ee35e66c55db4d728d15a6a4ada033","supportsFastUpdate":true}
    If (updCheck.version != lastID) {
        
        newVerURL := updCheck.url, newVerName := updCheck.name
        SplitPath newVerURL, dlName
        RunWait %SystemRoot%\System32\curl.exe -RO -z "%distDir%\%dlName%" "%newVerURL%", %distDir%, Min UseErrorLevel
        
        f := FileOpen(verfile, "w"), f.Write(updCheckRaw), f.Close()
        
        #include <find7zexe>
        RunWait "%exe7z%" x -aoa -o"%destPath%.%newVerName%" -- "%distDir%\%dlName%"
        RunWait "%exe7z%" x -aoa -o"%destPath%.%newVerName%" -- "%themePath%"
        RunWait %comspec% /C "RD "%destPath%" & MKLINK /J "%destPath%" "%destPath%.%newVerName%""
    }
} catch e {
    Throw e
}
Exit 0

#include <GetURL>
#include <JSON>
