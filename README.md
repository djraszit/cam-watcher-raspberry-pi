# cam-watcher-raspberry-pi

Opis:

Skrypty pomocne do automatycznego wyświetlania kamer na monitorze lub tv
po starcie raspberry-pi

Działa z kamerami Ganz 2MP i Internec 2MP.
Opóźnienie z kamer to około 0.5sek do 1.0sek
Można poeksperymentować z argumentami omxplayera,
może uda się uzyskać mniejsze opóźnienie

Próba kamery Dahua 4MP bez powodzenia, 
dopiero zmniejszenie rozdzielczości na 2MP zadziałało
Prawdopodobnie omxplayer nie obsługuje powyżej 2MP

Co do kamery Internec którą posiadam,
dosyć często zamraża obraz i restartuje omxplayer
Nie testowałem na innych kamerach


## Co potrzebne:

omxplayer
wiringpi - gpio do odczytu przycisków zmiany kanału
screen
sed
awk
fbset
socat


Proszę pisać wiadomości, co można by ulepszyć


