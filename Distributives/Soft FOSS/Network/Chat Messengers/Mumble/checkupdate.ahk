#NoEnv

;Original request:
;GET https://update.mumble.info/v1/version-check?ver=1.3.0&os=Win32&locale=en&sha1=6273ac0c8cc9067c31964317a14bea393c0280c2 HTTP/1.1
;User-Agent: Mozilla/5.0 (Win; 10.0.19042.1) Mumble/1.3.0 1.3.0
;Connection: Keep-Alive
;Accept-Encoding: gzip, deflate
;Accept-Language: ru-RU,en,*
;Host: update.mumble.info

checkresults := GetURL("https://update.mumble.info/v1/version-check?ver=1.3.0&os=Win32&locale=en")
