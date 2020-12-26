#!/bin/bash 


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
echo $DIR


TERM=linux setterm --background blue --clear all --blank 0 > /dev/tty0

ch1_crop="0 0 0 0"
ch2_crop="0 0 0 0"
ch3_crop="0 0 0 0"
ch4_crop="0 0 0 0"

#geometria ekranu i pozycje wyświetlania kamer
source $DIR/cam_position_src.sh

ch_urls=("ch1" "rtsp://192.168.1.65/0" "$full_screen" "$ch1_crop")
#ch_urls=("ch1" "rtsp://admin:Admin17395@192.168.1.108/live" "$full_screen" "$ch1_crop")
ch_urls+=("ch2" "rtsp://192.168.1.67/0" "$full_screen" "$ch2_crop")
ch_urls+=("ch3" "rtsp://ADMIN:1234@192.168.1.68/snl/live/1/1" "$full_screen" "$ch3_crop")
ch_urls+=("ch4" "rtsp://192.168.1.64:7053/PSIA/streaming/channels/101" "$full_screen" "$ch4_crop")

#nazwa pliku z aktualnie wyświetlanym kanałem
cam_ch_src="$DIR/cam_num"

cam_ch="allcam"

layer=1

if [ -e $cam_ch_src ];then
	cam_ch=$(cat $cam_ch_src)
	if [ "$cam_ch" == "allcam" ];then
		ch_urls[2]=$top_left_pos
		ch_urls[6]=$top_right_pos
		ch_urls[10]=$bottom_left_pos
		ch_urls[14]=$bottom_right_pos
	else
		ch_urls[2]=$full_screen
		ch_urls[6]=$full_screen
		ch_urls[10]=$full_screen
		ch_urls[14]=$full_screen
	fi
fi

#example: play ch1 $ch1_url $top_left_pos $ch1_crop
function play(){
	echo "PLAY $#"
	if [ $# == 3 ];then
		omxplayer --layer 1 --dbus_name org.mpris.MediaPlayer2.omxplayer.$1 --avdict rtsp_transport:tcp --win "$2" $3 --live -n -1
	elif [ $# == 4 ];then
		omxplayer --layer 1 --dbus_name org.mpris.MediaPlayer2.omxplayer.$1 --avdict rtsp_transport:tcp --win "$2" --crop "$3" $4 --live -n -1
	fi
}

OMXPLAYER_ARGS="--threshold 0.5 --live -n -1"

# Start displaying camera feeds 
case "$1" in 
start) 
unset CMD
CMD=
for ((i = 0; i < ${#ch_urls[@]}; i = i + 4));do 
	name=${ch_urls[i]} 
	url=${ch_urls[i+1]} 
	pos=${ch_urls[i+2]} 
	crop=${ch_urls[i+3]}
	
	if [ "$2" == "$cam_ch" ];then
		layer=5
	else
		layer=1
	fi

	if [ "$2" == "$name" ];then
		echo "$name,$url,$pos,$crop"
		if [ "$crop" == "0 0 0 0" ];then 
			CMD="screen -dmS \"$name\" sh -c 'omxplayer --layer $layer --dbus_name org.mpris.MediaPlayer2.omxplayer.$name --avdict rtsp_transport:tcp --win \"$pos\" $url $OMXPLAYER_ARGS'"
		#play $name "$pos" $url
		else
			CMD="screen -dmS \"$name\" sh -c 'omxplayer --layer $layer --dbus_name org.mpris.MediaPlayer2.omxplayer.$name --avdict rtsp_transport:tcp --win \"$pos\" --crop \"$crop\" $url $OMXPLAYER_ARGS'"
		#play $name "$pos" "$crop" $url
		fi
	fi
done 
eval $CMD
echo "Camera Display Started" 
;;


# Stop displaying camera feeds 
stop) 
screen -S $2 -X quit
#./omxplayer-dbus-control $2 stop
echo "Camera Display Ended" 
;;


*) 
echo "Usage: displaycameras {start|stop} ch1" 
exit 1

;; 
esac 
