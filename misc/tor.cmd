@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

rem https://www.torproject.org/docs/tor-manual.html.en
MKDIR "%LOCALAPPDATA%\Tor-from-browser-bundle"
PUSHD "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Tor" && (
    "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Tor\tor.exe" --defaults-torrc "..\Data\Tor\torrc-defaults" -f "..\Data\Tor\torrc" DataDirectory "%LOCALAPPDATA%\Tor-from-browser-bundle" GeoIPFile "..\Data\Tor\geoip" GeoIPv6File "..\Data\Tor\geoip6" HashedControlPassword 16:d537bbfdf7f6c97f60c61a50395251d9e378b54e2f61139c8082978bd4 +__SocksPort "127.0.0.1:1080 IPv6Traffic PreferIPv6 KeepAliveIsolateSOCKSAuth" Log "notice stdout" | cat
    rem Recognized severity levels are debug, info, notice, warn, and err
    rem +__ControlPort 9151 __OwningControllerProcess 8020
    POPD
)
PAUSE
)
