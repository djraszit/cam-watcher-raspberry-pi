#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

cam_num_file="$DIR/cam_num"
source $DIR/cam_position_src.sh
source $DIR/channel_names

#piny gpio do zmiany wyświetlanego kanału
inc_btn=21
dec_btn=20

gpio -g mode $inc_btn input
gpio -g mode $inc_btn up
gpio -g mode $dec_btn input
gpio -g mode $dec_btn up

send="0 5 40 ${chname[0]}!\n960 5 40 ${chname[1]}!\n0 548 40 ${chname[2]}!\n960 548 40 ${chname[3]}!\n"
if [ -e /tmp/hello_font_by_raszit ]; then
	echo -e "$send" | socat STDIO UNIX-CONNECT:/tmp/hello_font_by_raszit,connect-timeout=1
fi


cam_switcher(){

	crop=("0 0 0 0")
	crop+=("200 200 1720 880")
	crop+=("400 400 1320 680")
	crop+=("0 0 960 560")

	crops=$((${#crop[@]} - 1))
	cropnum=0;

	while [ true ];do
		btn_up=$(gpio -g read $inc_btn)
		btn_dn=$(gpio -g read $dec_btn)
		if [ $btn_up == "0" ];then
			cropnum=$((cropnum + 1));
			if [ $cropnum -gt $crops ];then
				cropnum=0
			fi
		fi
		if [ $btn_dn == "0" ];then
			cropnum=$((cropnum - 1));
			if [ $cropnum -lt 0 ];then
				cropnum=$crops
			fi
		fi
		if [ $btn_dn == "0" -o $btn_up == "0" ];then
			$DIR/omxplayer-dbus-control.sh ch1 setvideocroppos ${crop[cropnum]}
			if [ $cropnum -eq 0 ];then
				text="full area"
			else
				text="ch $cropnum"
			fi
			/opt/vc/src/hello_pi/hello_font/hello_font.bin pos_x 100 pos_y 800 text "$text" disptime 2 size 200
		fi
		sleep 0.1;
	done
}

cam_layer_switcher(){

	cam_on_top=0
	cam_num=4

	if [ -e $cam_num_file ];then
		temp=$(cat $cam_num_file)
		if [ "${temp:0:2}" == "ch" ];then
			cam_on_top=${temp:2}
		fi
		if [ "$temp" == "allcam" ];then
			cam_on_top=0
		fi
	fi


	while [ true ];do
		btn_up=$(gpio -g read $inc_btn)
		btn_dn=$(gpio -g read $dec_btn)
		if [ $btn_up == "0" ];then
			cam_on_top=$((cam_on_top + 1));
			if [ $cam_on_top -gt $cam_num ];then
				cam_on_top=0
			fi
		fi
		if [ $btn_dn == "0" ];then
			cam_on_top=$((cam_on_top - 1));
			if [ $cam_on_top -lt 0 ];then
				cam_on_top=$cam_num
			fi
		fi

		if [ $btn_dn == "0" -o $btn_up == "0" ];then
			if [ $cam_on_top -gt 0 ];then
				for ((l = 1; l <= $cam_num; l++));do			
					$DIR/omxplayer-dbus-control.sh ch$l hidevideo
					$DIR/omxplayer-dbus-control.sh ch$l setvideopos $full_screen
				done
				for ((l = 1; l <= $cam_num; l++));do
					if [ $l -eq $cam_on_top  ];then
						$DIR/omxplayer-dbus-control.sh ch$l setlayer 5
						$DIR/omxplayer-dbus-control.sh ch$l unhidevideo
					else
						$DIR/omxplayer-dbus-control.sh ch$l setlayer 1
					fi
				done
				text="ch$cam_on_top"
				send="0 10 60 ${chname[cam_on_top - 1]}!\n"
			else
				$DIR/omxplayer-dbus-control.sh ch1 setvideopos $top_left_pos
				$DIR/omxplayer-dbus-control.sh ch2 setvideopos $top_right_pos
				$DIR/omxplayer-dbus-control.sh ch3 setvideopos $bottom_left_pos
				$DIR/omxplayer-dbus-control.sh ch4 setvideopos $bottom_right_pos
				for ((l = 1; l <= $cam_num; l++));do
					$DIR/omxplayer-dbus-control.sh ch$l unhidevideo
				done
				text="allcam"
				send="0 5 40 ${chname[0]}!\n960 5 40 ${chname[1]}!\n0 548 40 ${chname[2]}!\n960 548 40 ${chname[3]}!\n"
			fi

			echo "$text" > $DIR/cam_num

			if [ -e /tmp/hello_font_by_raszit ]; then
				echo -e "$send" | socat STDIO UNIX-CONNECT:/tmp/hello_font_by_raszit,connect-timeout=1
			fi
		fi

		sleep 0.1;
	done



}

#cam_switcher &
cam_layer_switcher &

