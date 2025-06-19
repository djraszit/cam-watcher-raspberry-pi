# cam-watcher-raspberry-pi

## Opis:

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

## Dodałem kilka nowych funkcji

1. Restart automatyczny o 00:00
2. Zmiana wyświetlanego kanału przez socket (TCP port 8001)
3. Wszystko w jednym slice

## Jak to zainstalować

Po prostu uruchamiamy w terminalu, może być przez ssh

'''bash
./install.sh
'''

Domyślnie instaluje się w /home/pi/cam-watcher + niektóre skrypty w /etc/systemd/system

Edytujemy plik display-cameras.sh

linijki zaczynające się na ch_urls zawierają adresy rtsp do strumieni z kamer

Jeśli nie chcemy korzystać z przycisków do zmiany kanału to po instalacji w terminalu:

systemctl stop cam-switcher.service

systemctl disable cam-switcher.service



