#!/bin/bash

echo "Instalator skryptów do wyświetlania kamer na monitorze lub tv"

INST_DIR=/home/pi/cam-watcher

OMXPLAYER=

#zależności
DEP=(omxplayer gpio screen sed awk fbset socat)

for i in ${DEP[@]};do
	INPUT=$(which $i)
	if [ "$INPUT" == "" ];then
		echo -e "$i nie znaleziono\n"
		echo "kończę"
		exit 1;
	elif [[ "$INPUT" =~ ^/*/ ]];then
		echo -e "$i znaloziono\n"
		if [ "$i" == "omxplayer" ];then
			OMXPLAYER=$INPUT
		fi
	fi
done

INSTALL_DIR=$(realpath $INST_DIR)

SOURCE_DIR=./to_install


echo -e "sprawdzam czy katalog docelowy istnieje\n"

if [ -d $INSTALL_DIR ];then
	echo -e "katalog docelowy istnieje\n"
else
	echo "tworzę katalog $INSTALL_DIR"
	mkdir $INSTALL_DIR
fi


DEST_DIR=$(dirname $OMXPLAYER)

if [ -e $OMXPLAYER.backup ];then
	echo -e "kopia skryptu omxplayer istnieje\n"
else
	echo "wykonuję kopię zapasową skryptu $OMXPLAYER"
	sudo mv $OMXPLAYER $OMXPLAYER.backup
	echo "kopiuję zmodyfikowaną wersję omxplayer z $SOURCE_DIR do $DEST_DIR"
	sudo cp $SOURCE_DIR/omxplayer $DEST_DIR
fi

#pliki do skopiowania
FILES=(display-cameras.sh cam-switcher.sh cam_position_src.sh omxplayer-dbus-control.sh \
								channel_names socket-cam-switcher.sh cam_num)

for i in ${FILES[@]};do
	if [ -e $INSTALL_DIR/$i ];then
		echo -e "skrypt: $i istnieje\n"
	else
		echo -e "instaluje: $i do $INSTALL_DIR\n"
		cp $SOURCE_DIR/$i $INSTALL_DIR
	fi
done


SYSTEMD_DIR=/etc/systemd/system
SCRIPTS=("displaycameras.slice")
SCRIPTS+=("display-camera@.service")
SCRIPTS+=("display-cameras-restart.service")
SCRIPTS+=("display-cameras-restart.timer")
SCRIPTS+=("cam-switcher.service")
SCRIPTS+=("socket-cam-switcher@.service")
SCRIPTS+=("socket-cam-switcher.socket")

for i in ${SCRIPTS[@]};do
	if [ -e $SYSTEMD_DIR/$i ];then
		echo -e "skrypt: $i istnieje\n"
	else
		echo -e "instaluje: $i do $SYSTEMD_DIR\n"
		sudo cp $SOURCE_DIR/$i $SYSTEMD_DIR
	fi
done

sudo sed -i '/ExecStart/d' $SYSTEMD_DIR/display-camera@.service
sudo sed -i '/ExecStop/d' $SYSTEMD_DIR/display-camera@.service

sudo sed -i '/Type=forking/a\ExecStop='"$INSTALL_DIR/display-cameras.sh stop %i" $SYSTEMD_DIR/display-camera@.service
sudo sed -i '/Type=forking/a\ExecStart='"$INSTALL_DIR/display-cameras.sh start %i" $SYSTEMD_DIR/display-camera@.service

sudo sed -i '/ExecStart/d' $SYSTEMD_DIR/cam-switcher.service

sudo sed -i '/Type=forking/a\ExecStart='"$INSTALL_DIR/cam-switcher.sh" $SYSTEMD_DIR/cam-switcher.service

sudo sed -i '/ExecStart/d' $SYSTEMD_DIR/socket-cam-switcher@.service

sudo sed -i '/Type=simple/a\ExecStart='"$INSTALL_DIR/socket-cam-switcher.sh" $SYSTEMD_DIR/socket-cam-switcher@.service

sudo systemctl daemon-reload

sudo systemctl enable cam-switcher.service
sudo systemctl start cam-switcher.service

sudo systemctl enable socket-cam-switcher.socket
sudo systemctl start socket-cam-switcher.socket

sudo systemctl enable display-camera@ch1.service
sudo systemctl start display-camera@ch1.service

sudo systemctl enable display-camera@ch2.service
sudo systemctl start display-camera@ch2.service

sudo systemctl enable display-camera@ch3.service
sudo systemctl start display-camera@ch3.service

sudo systemctl enable display-camera@ch4.service
sudo systemctl start display-camera@ch4.service

sudo systemctl enable display-cameras-restart.timer
